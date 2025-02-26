import           XMonad
import           XMonad.Actions.CopyWindow
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.StatusBar
import           XMonad.Hooks.StatusBar.PP
import           XMonad.Hooks.TaffybarPagerHints (pagerHints)
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Renamed
import           XMonad.Layout.Spacing
import           XMonad.Layout.Tabbed
import           XMonad.Prompt
import           XMonad.Prompt.Input
import           XMonad.Util.EZConfig
import qualified XMonad.Util.ExtensibleState as XS
import           XMonad.Util.Hacks (fixSteamFlicker)
import           XMonad.Util.Loggers
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
fg, mg, bg :: String
fg = "#ffffff"
mg = "#555555"
bg = "#222222"

data State = State { brightness :: Float
                  }

instance ExtensionClass State where
  initialValue = State { brightness = 1.0
                       }

main :: IO ()
main = xmonad $ docks $ ewmhFullscreen $ ewmh $ myConfig

myPromptConfig :: XPConfig
myPromptConfig = def
  { bgColor = bg
  , fgColor = fg
  , promptBorderWidth = 0
  , height = 33
  , position = Top
  , font = "GohuFont:pixelsize=12"
  }
  
powerPrompt :: X ()
powerPrompt =
  inputPromptWithCompl myPromptConfig "Poweroff"
  (mkComplFunFromList def ["poweroff", "reboot", "suspend"]) ?+ handle
  where
    handle "poweroff" = spawn "systemctl poweroff"
    handle "reboot" = spawn "systemctl reboot"
    handle "suspend" =spawn "systemctl suspend"
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
  | delta > 0 = spawn $ "pamixer -i "
                ++ show delta ++
                " && notify-send -t 1000 -h int:value:$(pamixer --get-volume) \"Volume\""
  | delta < 0 = spawn $ "pamixer -d "
                ++ show (abs delta) ++
                " && notify-send -t 1000 -h int:value:$(pamixer --get-volume) \"Volume\""
  | otherwise = spawn "notify-send -t 1000 \"Unknown value\""

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
    , ("M-f"                    , spawn "polybar-msg cmd toggle")
    , ("<XF86AudioRaiseVolume>" , adjustVolume (5))
    , ("<XF86AudioLowerVolume>" , adjustVolume (-5))
    , ("M-S-p"                  , powerPrompt)
    , ("M-a"                    , windows copyToAll) -- Pin to all workspaces
    , ("M-S-a"                  , killAllOtherCopies) -- remove window from all but current
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
  -- Fixes `xdg-open`. See here: https://www.reddit.com/r/NixOS/comments/193hk48/comment/khbtfy9/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  spawnOnce "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"

myLayout = (spacing 5 $ named "1/2 tiled" $ Tall 1 delta (1/2))
  ||| (spacing 5 $ named "2/3 tiled" $ Tall 1 delta (2/3))
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

