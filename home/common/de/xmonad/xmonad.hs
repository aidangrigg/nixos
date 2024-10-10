import           XMonad
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.StatusBar
import           XMonad.Hooks.StatusBar.PP
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Renamed
import           XMonad.Layout.Spacing
import           XMonad.Layout.Tabbed
import           XMonad.Util.EZConfig
import           XMonad.Util.Loggers
import           XMonad.Util.Run (spawnPipe)

import           Data.List.NonEmpty (toList, NonEmpty)
import           Data.Maybe
import           Data.Org
import           Data.Time (Day, TimeOfDay(..), fromGregorian, showGregorian)
import           Text.Printf (printf)

import qualified Data.Text as T
import qualified Data.Text.IO as TIO

--  Default programs
terminal, browser, launcher, emacs :: String
terminal = "alacritty"
browser  = "firefox"
launcher = "rofi -show drun"
emacs = "emacsclient -c"

main :: IO ()
main = do
  xmonad
    . ewmhFullscreen
    . ewmh
    . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) toggleStrutsKey
    $ myConfig
    where
      toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
      toggleStrutsKey XConfig{ modMask = m } = (m, xK_c)

noNameLayout = named ""

myConfig = def
    { modMask    = mod4Mask      -- Rebind Mod to the Super key
    , layoutHook = smartBorders $ myLayout      -- Use custom layouts
    , manageHook = myManageHook  -- Match on certain windows
    , normalBorderColor = "#111111"
    , focusedBorderColor = "#FFFFFF"
    }
  `additionalKeysP`
    [ ("M-b"        ,       spawn Main.browser)
    , ("M-<Return>" ,       spawn Main.terminal)
    , ("M-S-q"      ,       kill)
    , ("M-S-e"      ,       spawn Main.emacs)
    , ("M-d"        ,       spawn Main.launcher)
    , ("M-q"        ,       spawn "xmonad --restart")
    ]

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , isDialog            --> doFloat
    ]


myLayout = (named "tiled" $ smartSpacing 5 $ tiled) ||| (named "tabbed" $ tabbed shrinkText myTabConfig)
  where
    tiled    = Tall nmaster delta ratio
    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 2/3    -- Default proportion of screen occupied by master pane
    delta    = 3/100  -- Percent of screen to increment by when resizing panes
    myTabConfig = def { activeColor = fg
                      , inactiveColor = bg
                      , activeTextColor = bg
                      , inactiveTextColor = fg
                      , activeBorderColor = fg
                      , inactiveBorderColor = bg}

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = " // "
    , ppCurrent         = (ppColor fg) . wrap "[" "]"
    , ppHidden          = (ppColor fg) . wrap " " " "
    , ppLayout          = (ppColor fg)
    , ppOrder           = \[w,l,_,o] -> [w,l, (ppColor fg) o]
    , ppExtras          = [orgTodoLogger]
    }
  where
    orgTodoLogger :: X (Maybe String)
    orgTodoLogger = do
      f <- liftIO (TIO.readFile "/home/aidan/sync/notes/org/tasks.org")
      return $ (org f) >>= (closestTodosPP . closestTodos)

    ppColor :: String -> String -> String
    ppColor c = xmobarColor c ""

fg, mg, bg :: String
fg = "#ffffff"
mg = "#555555"
bg = "#222222"

------------------------------------------------------------------------------------
-- ORG TODOS                                                                      --
------------------------------------------------------------------------------------

data ClosestTodos = ClosestTodos
  { todoDeadline :: Maybe Section
  , todoScheduled :: Maybe Section
  }

getTodosWithTimestamp :: OrgDoc -> ([Section], [Section])
getTodosWithTimestamp OrgDoc{docSections = secs} =
  (deadlines, scheduled)
  where
    sections = flattenSections secs
    todos = filter (isTodo . sectionTodo) sections
    deadlines = filter (isJust . sectionDeadline) todos
    scheduled = filter (isJust . sectionScheduled) todos

    isTodo :: Maybe Todo -> Bool
    isTodo Nothing = False
    isTodo (Just t) =
      case t of
        TODO -> True
        DONE -> False
        
    flattenSections :: [Section] -> [Section]
    flattenSections [] = []
    flattenSections (x:xs) =
      [x] ++ flattenSections ((docSections . sectionDoc) x) ++ flattenSections xs

closestTodos :: OrgFile -> ClosestTodos
closestTodos (OrgFile _ doc) =
  (ClosestTodos d s)
  where
    (deadlines, schedules) = getTodosWithTimestamp doc

    compareSectionDeadline :: Section -> Section -> Section
    compareSectionDeadline s1 s2 =
      if (sectionDeadline s1) < (sectionDeadline s2)
      then s1 else s2

    compareSectionSchedule :: Section -> Section -> Section
    compareSectionSchedule s1 s2 =
      if (sectionScheduled s1) < (sectionScheduled s2)
      then s1 else s2

    d = if null deadlines
      then Nothing
      else Just $ foldr1 compareSectionDeadline deadlines

    s = if null schedules
      then Nothing
      else Just $ foldr1 compareSectionSchedule schedules

formatTodo :: String -> NonEmpty Words -> Maybe OrgDateTime -> String
formatTodo p title (Just time) =
  formatTodo p title Nothing
  ++ " <" ++ (prettyDateTime time) ++ ">"

formatTodo p title Nothing =
  "[" ++ p ++ "] "
  ++ (shorten 20 $ unwords $ map (T.unpack . prettyWords) $ toList title)

closestTodosPP :: ClosestTodos -> Maybe String
closestTodosPP (ClosestTodos Nothing Nothing) = Nothing
closestTodosPP (ClosestTodos (Just dl) Nothing) =
  Just $ formatTodo "D" (sectionHeading dl) (sectionDeadline dl)

closestTodosPP (ClosestTodos Nothing (Just sh)) =
  Just $ formatTodo "S" (sectionHeading sh) (sectionScheduled sh)

closestTodosPP t@(ClosestTodos dl sh) =
  Just
  $ unwords
  $ catMaybes [ closestTodosPP t { todoScheduled = Nothing }
              , closestTodosPP t { todoDeadline = Nothing }]

-- these functions are "borrowed" from org-mode
prettyDateTime :: OrgDateTime -> String
prettyDateTime (OrgDateTime d w t rep del) =
  unwords $ catMaybes [ Just d', Just w', prettyTime <$> t ]
  where
    d' :: String
    d' = showGregorian d

    w' :: String
    w' = take 3 $ show w

prettyTime :: OrgTime -> String
prettyTime (OrgTime s me) = tod s ++ maybe "" (\e -> "-" ++ tod e) me
  where
    tod :: TimeOfDay -> String
    tod (TimeOfDay h m _) = printf "%02d:%02d" h m
