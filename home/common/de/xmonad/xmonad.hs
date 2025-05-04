import           XMonad
import           XMonad.Actions.CopyWindow
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.StatusBar
import           XMonad.Hooks.StatusBar.PP
import           XMonad.Layout.Grid
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Renamed
import           XMonad.Layout.Spacing
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ToggleLayouts
import           XMonad.Prompt
import           XMonad.Prompt.Input
import qualified XMonad.StackSet as W
import           XMonad.Util.ClickableWorkspaces
import           XMonad.Util.EZConfig
import qualified XMonad.Util.ExtensibleState as XS
import           XMonad.Util.Hacks (fixSteamFlicker)
import           XMonad.Util.Loggers
import           XMonad.Util.NamedScratchpad
import           XMonad.Util.PureX (toX)
import           XMonad.Util.Run (spawnPipe)
import           XMonad.Util.SpawnOnce

import           Data.List.NonEmpty (toList, NonEmpty)
import           Data.Maybe
-- import           Data.Org
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

-- Colours
fg, fgDim, mg, bg :: String
fg = "#ffffff"
fgDim = "#AAAAAA"
mg = "#555555"
bg = "#222222"

data State = State { brightness :: Float
                  }

instance ExtensionClass State where
  initialValue = State { brightness = 1.0
                       }

main :: IO ()
main = xmonad
  . withEasySB (statusBarProp "xmobar" (clickablePP myXmobarPP)) toggleStrutsKey
  . docks
  . ewmhFullscreen
  . ewmh
  $ myConfig
  where
    toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
    toggleStrutsKey XConfig{ modMask = m } = (m, xK_c)

myPromptConfig :: XPConfig
myPromptConfig = def
  { bgColor = bg
  , fgColor = fg
  , promptBorderWidth = 0
  , height = 33
  , position = Top
  , font = "xft:GohuFont:size=12"
  }
  
powerPrompt :: X ()
powerPrompt =
  inputPromptWithCompl myPromptConfig "Poweroff"
  (mkComplFunFromList def ["poweroff", "reboot", "suspend"]) ?+ handle
  where
    handle "poweroff" = spawn "systemctl poweroff"
    handle "reboot" = spawn "systemctl reboot"
    handle "suspend" = spawn "i3lock 5 3 && systemctl suspend"
    handle _ = spawn "notify-send -t 1000 \"Unknown value\""

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

adjustVolume :: Int -> X ()
adjustVolume delta
  | delta > 0 = f $ "pamixer -i " ++ show delta
  | delta < 0 = f $ "pamixer -d " ++ show (abs delta)
  | otherwise = spawn "notify-send -t 1000 \"Unknown value\""
  where
    f = spawn . (++ " && notify-send -t 1000 -h int:value:$(pamixer --get-volume) \"Volume\"")


myConfig = def
    { modMask    = mod4Mask
    , layoutHook = avoidStruts $ lessBorders Never $ noBorders $ myLayout
    , manageHook = myManageHook
    , normalBorderColor = "#222222"
    , focusedBorderColor = "#FFFFFF"
    , startupHook = myStartupHook
    , handleEventHook = fixSteamFlicker
    }
  `additionalKeysP`
    [ ("M-b"                    , spawn Main.browser)
    , ("M-<Return>"             , spawn Main.terminal)
    , ("M-S-q"                  , kill)
    , ("M-S-e"                  , spawn Main.emacs)
    , ("M-d"                    , spawn Main.launcher)
    , ("M-q"                    , spawn "xmonad --restart")
    , ("M-s"                    , spawn "maim -s | xclip -selection clipboard -t image/png")
    , ("M-S-s"                  , spawn "peek")
    , ("M-<U>"                  , adjustBrightness 0.1)
    , ("M-<D>"                  , adjustBrightness (-0.1))
    , ("M-e"                    , spawn fileBrowser)
    , ("M-f"                    , sendMessage (Toggle "full") >> sendMessage ToggleStruts)
    , ("<XF86AudioRaiseVolume>" , adjustVolume (5))
    , ("<XF86AudioLowerVolume>" , adjustVolume (-5))
    , ("M-S-p"                  , powerPrompt)
    , ("M-p"                    , windows copyToAll) -- Pin to all workspaces
    , ("M-S-a"                  , killAllOtherCopies) -- remove window from all but current
    , ("M-S-l"                  , spawn "i3lock 5 3") -- lock screen
    , ("M-a M-o"                  , namedScratchpadAction myScratchpads "org")
    , ("M-a M-d"                  , namedScratchpadAction myScratchpads "discord")
    ]

-- Window rules
rectCentered :: Rational -> W.RationalRect
rectCentered percentage = W.RationalRect offset offset percentage percentage
  where
    offset = (1 - percentage) / 2

myScratchpads =
  [ NS "discord" "flatpak run com.discordapp.Discord" (className =? "discord") $ customFloating (rectCentered 0.7)
  , NS "org" "emacs --title='orgmacs' --eval='(org-agenda-list)' -g '140x40'" (title =? "orgmacs") $ customFloating (rectCentered 0.6)
  ]

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , className =? "Peek" --> doFloat
    , isFullscreen        --> doFullFloat
    , isDialog            --> doFloat
    ] <+> namedScratchpadManageHook myScratchpads

myStartupHook = do
  spawnOnce "xrandr -r 165" -- refresh rate
  spawnOnce "feh --bg-scale /home/aidan/images/background/cloud.png" -- background
  spawnOnce "xsetroot -cursor_name Quintom_Ink" -- set cursor theme
  -- Fixes `xdg-open`. See here: https://www.reddit.com/r/NixOS/comments/193hk48/comment/khbtfy9/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  spawnOnce "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"

my_half = spacing 3 $ Tall 1 (3/100) (1/2)
my_twothirds = spacing 3 $ Tall 1 (3/100) (2/3)
my_grid = spacing 3 Grid
my_tabbed = spacing 3 $ tabbedBottom shrinkText myTabConfig
  where
    myTabConfig = def { activeColor = fg
                      , inactiveColor = bg
                      , activeTextColor = bg
                      , inactiveTextColor = fg
                      , activeBorderColor = fg
                      , inactiveBorderColor = bg
                      , fontName = "GohuFont"
                      , decoHeight = 20}


myLayout = toggleLayouts (named "full" Full)
  (named "1/2" my_half
   ||| named "2/3" my_twothirds 
   ||| named "tabbed" my_tabbed
   ||| named "grid" my_grid)

sep = xmobarColor mg "" " // "

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = sep
    , ppCurrent         = (ppColor fg) . wrap "[" "]"
    , ppHidden          = (ppColor fgDim) . wrap " " " "
    , ppLayout          = (ppColor fg)
    , ppOrder           = \[w,_,_] -> [w]
    -- , ppExtras          = [orgTodoLogger]
    }
  where
    -- orgTodoLogger :: X (Maybe String)
    -- orgTodoLogger = do
    --   f <- liftIO (TIO.readFile "/home/aidan/sync/notes/org/tasks.org")
    --   return $ (org f) >>= (closestTodosPP . closestTodos)

    ppColor :: String -> String -> String
    ppColor c = xmobarColor c ""

