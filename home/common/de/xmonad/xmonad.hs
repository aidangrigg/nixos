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
import qualified XMonad.Util.ExtensibleState as XS
import           XMonad.Util.Hacks (fixSteamFlicker)
import           XMonad.Util.Loggers
import           XMonad.Util.PureX (toX)
import           XMonad.Util.Run (spawnPipe)
import           XMonad.Util.SpawnOnce
import           XMonad.Hooks.TaffybarPagerHints (pagerHints)

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
fileBrowser = "nemo"

data State = State { brightness :: Float
                   }

instance ExtensionClass State where
  initialValue = State { brightness = 1.0
                       }

main :: IO ()
main = xmonad $ docks $ ewmh $ pagerHints $ myConfig

noNameLayout = named ""

adjustBrightness :: Float -> X ()
adjustBrightness delta = do
    s <- XS.get
    let newBrightness = brightness s + delta
    let clampedBrightness = max 0 (min 1.0 newBrightness)
    XS.put $ s { brightness = clampedBrightness }
    spawn $ "xrandr --output DP-1 --brightness " ++ show clampedBrightness
    spawn $ "xrandr --output DP-2 --brightness " ++ show clampedBrightness

    spawn $ "notify-send -t 1000 -h int:value:"
      ++ show (clampedBrightness * 100)
      ++ " \"Brightness\""


myConfig = def
    { modMask    = mod4Mask
    , layoutHook = avoidStruts $ smartSpacing 5 $ lessBorders Never $ noBorders $ myLayout
    , manageHook = myManageHook
    , normalBorderColor = "#222222"
    , focusedBorderColor = "#FFFFFF"
    , startupHook = myStartupHook
    , handleEventHook = fixSteamFlicker
    }
  `additionalKeysP`
    [ ("M-b"        ,       spawn Main.browser)
    , ("M-<Return>" ,       spawn Main.terminal)
    , ("M-S-q"      ,       kill)
    , ("M-S-e"      ,       spawn Main.emacs)
    , ("M-d"        ,       spawn Main.launcher)
    , ("M-q"        ,       spawn "xmonad --restart")
    , ("M-s"        ,       spawn "maim -s | xclip -selection clipboard -t image/png")
    , ("M-S-s"      ,       spawn "peek")
    , ("M-<U>"      ,       adjustBrightness 0.1)
    , ("M-<D>"      ,       adjustBrightness (-0.1))
    , ("M-e"        ,       spawn fileBrowser)
    , ("M-f"        ,       spawn "polybar-msg cmd toggle")
    ]

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , className =? "Peek" --> doFloat
    , isDialog            --> doFloat
    ]

myStartupHook = do
  spawnOnce "xrandr -r 165" -- refresh rate
  spawnOnce "feh --bg-scale /home/aidan/images/background/cloud.png" -- background
  spawnOnce "xsetroot -cursor_name Quintom_Ink" -- set cursor theme
  spawnOnce "systemctl --user restart polybar"

myLayout = (named "1/2 tiled" $ Tall 1 delta (1/2))
  ||| (named "2/3 tiled" $ Tall 1 delta (2/3))
  ||| (named "tabbed" $ tabbedBottom shrinkText myTabConfig)
  where
    delta    = 3/100  -- Percent of screen to increment by when resizing panes
    myTabConfig = def { activeColor = fg
                      , inactiveColor = bg
                      , activeTextColor = bg
                      , inactiveTextColor = fg
                      , activeBorderColor = fg
                      , inactiveBorderColor = bg
                      , fontName = "GohuFont"
                      , decoHeight = 20}

sep = xmobarColor mg "" " // "

myXmobarPP :: PP

myXmobarPP = def
    { ppSep             = sep
    , ppCurrent         = (ppColor fg) . wrap "[" "]"
    , ppHidden          = (ppColor fg) . wrap " " " "
    , ppLayout          = (ppColor fg)
    , ppOrder           = \[w,l,_] -> [w,l]
    -- , ppExtras          = [orgTodoLogger]
    }
  where
    -- orgTodoLogger :: X (Maybe String)
    -- orgTodoLogger = do
    --   f <- liftIO (TIO.readFile "/home/aidan/sync/notes/org/tasks.org")
    --   return $ (org f) >>= (closestTodosPP . closestTodos)

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
              , Just sep
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
