import           XMonad
import           XMonad.Actions.CopyWindow
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.StatusBar
import           XMonad.Hooks.StatusBar.PP
import           XMonad.Hooks.SetWMName
import           XMonad.Layout.Grid
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Renamed
import           XMonad.Layout.Spacing
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ToggleLayouts
import           XMonad.Prompt
import           XMonad.Prompt.Input
import           XMonad.Prompt.FuzzyMatch
import qualified XMonad.StackSet as W
import           XMonad.Util.ClickableWorkspaces
import           XMonad.Util.EZConfig
import qualified XMonad.Util.ExtensibleState as XS
import           XMonad.Util.Hacks (fixSteamFlicker)
import           XMonad.Util.Loggers
import qualified XMonad.Util.NamedScratchpad as NSP
import           XMonad.Util.PureX (toX)
import           XMonad.Util.Run (spawnPipe, runProcessWithInput)
import           XMonad.Util.SpawnOnce
import           XMonad.Util.Dmenu


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
bg = "#000000"

data BrightnessState = BrightnessState { brightness :: Float }

instance ExtensionClass BrightnessState where
  initialValue = BrightnessState { brightness = 1.0 }

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

data Power = Power

instance XPrompt Power where
  showXPrompt       Power = "> "
  commandToComplete _ c  = c
  nextCompletion      _  = getNextCompletion

myPromptConfig :: XPConfig
myPromptConfig = def
  { bgColor = bg
  , fgColor = fg
  , borderColor = fg
  , alwaysHighlight = True
  , promptBorderWidth = 1
  , height = 30
  , position = CenteredAt { xpCenterY = 0.4, xpWidth = 0.3 }
  , font = "xft:Iosevka:size=12"
  , maxComplRows = Just 20
  , maxComplColumns = Just 1
  }

powerPrompt :: X ()
powerPrompt =
  mkXPrompt Power myPromptConfig
  (mkComplFunFromList' def ["off", "reboot", "zzz"]) handle
  where
    handle "off" = spawn "systemctl poweroff"
    handle "reboot" = spawn "systemctl reboot"
    handle "zzz" = spawn "i3lock 5 3 && systemctl suspend"
    handle _ = spawn "notify-send -t 1000 \"Unknown value\""

switchAudioInput :: X ()
switchAudioInput =
  mkXPrompt Power myPromptConfig
  (mkComplFunFromList' def ["headphones", "speakers"]) handle
  where
    handle "headphones" = spawn "pactl set-default-sink 'alsa_output.pci-0000_13_00.6.analog-stereo' && notify-send 'Switched to headphones'"
    handle "speakers" = spawn "pactl set-default-sink 'alsa_output.pci-0000_03_00.1.hdmi-stereo-extra1' && notify-send 'Switched to speakers'"
    handle opt = spawn $ "notify-send 'Unknown option: " ++ show opt ++ "'"

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

data ScratchpadState = ScratchpadState String

instance ExtensionClass ScratchpadState where
  initialValue = ScratchpadState "org"

activatePreviousScratchpad = do
  (ScratchpadState previous) <- XS.get
  NSP.namedScratchpadAction myScratchpads previous

activateScratchpad n =
  XS.put (ScratchpadState n) >> NSP.namedScratchpadAction myScratchpads n

myConfig = def
    { modMask    = mod4Mask
    , layoutHook = avoidStruts $ smartBorders $ myLayout
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
    , ("M-e"                    , spawn Main.emacs)
    , ("M-x"                    , spawn Main.launcher)
    , ("M-q"                    , refresh)
    , ("M-s"                    , spawn "maim -u | feh -F - & maim -s | xclip -selection clipboard -t image/png && kill $!")
    , ("M-S-s"                  , spawn "peek")
    , ("M-<U>"                  , adjustBrightness 0.05)
    , ("M-<D>"                  , adjustBrightness (-0.05))
    , ("M-S-e"                  , spawn fileBrowser)
    , ("M-f"                    , sendMessage (Toggle "full") >> sendMessage ToggleStruts)
    , ("<XF86AudioRaiseVolume>" , adjustVolume (5))
    , ("<XF86AudioLowerVolume>" , adjustVolume (-5))
    , ("M-S-p"                  , powerPrompt)
    , ("M-p"                    , windows copyToAll) -- Pin to all workspaces
    , ("M-S-a"                  , killAllOtherCopies) -- remove window from all but current
    , ("M-S-l"                  , spawn "i3lock 5 3") -- lock screen
    , ("M-o"                    , activateScratchpad "org")
    , ("M-d"                    , activateScratchpad "discord")
    , ("M-m"                    , activateScratchpad "ncmpcpp")
    , ("M-<Tab>"                , activatePreviousScratchpad)
    , ("M-a"                    , switchAudioInput)
    ]

-- Window rules
rectCentered :: Rational -> W.RationalRect
rectCentered percentage = W.RationalRect offset offset percentage percentage
  where
    offset = (1 - percentage) / 2

myScratchpads =
  [ NSP.NS "discord" "flatpak run com.discordapp.Discord" (className =? "discord") $ NSP.customFloating (rectCentered 0.8)
  , NSP.NS "org" "emacs --title='orgmacs' --eval='(org-agenda-list) (org-alert-disable)' -g '140x40'" (title =? "orgmacs") $ NSP.customFloating (rectCentered 0.8)
  , NSP.NS "ncmpcpp" "alacritty --title ncmpcpp -e ncmpcpp" (title =? "ncmpcpp") $ NSP.customFloating (rectCentered 0.9)
  ]

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , className =? "Peek" --> doFloat
    , isFullscreen        --> doFullFloat
    , isDialog            --> doFloat
    ] <+> NSP.namedScratchpadManageHook myScratchpads

myStartupHook = do
  spawnOnce "xrandr -r 165" -- refresh rate
  spawnOnce "feh --bg-scale /home/aidan/images/background/cloud.png" -- background
  spawnOnce "xsetroot -cursor_name Quintom_Ink" -- set cursor theme
  -- Fixes `xdg-open`. See here:
  --  https://www.reddit.com/r/NixOS/comments/193hk48/comment/khbtfy9/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  spawnOnce "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"
  setWMName "LG3D"

my_half = Tall 1 (3/100) (1/2)
my_twothirds = Tall 1 (3/100) (2/3)
my_grid =  Grid
my_tabbed = tabbedBottom shrinkText myTabConfig
  where
    myTabConfig = def { activeColor = fg
                      , inactiveColor = bg
                      , activeTextColor = bg
                      , inactiveTextColor = fg
                      , activeBorderColor = fg
                      , inactiveBorderColor = bg
                      , fontName = "Iosevka"
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
    }
  where
    ppColor :: String -> String -> String
    ppColor c = xmobarColor c ""

