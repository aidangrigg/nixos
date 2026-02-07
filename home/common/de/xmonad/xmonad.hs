import           XMonad
import           XMonad.Actions.CopyWindow
import           XMonad.Actions.OnScreen
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
import           XMonad.Layout.MultiToggle
import           XMonad.Layout.MultiToggle.Instances
import           XMonad.Layout.SimpleFloat
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
fg, fgDim, hl, bg :: String
fg = "#1c0810"
fgDim = "#63728f"
hl = "#71958d"
bg = "#fffff2"

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
    toggleStrutsKey XConfig{ modMask = m } = (m, xK_VoidSymbol)

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
    spawn $ "xrandr --output HDMI-2 --brightness " ++ show clampedBrightness
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
    , layoutHook = myLayout
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
    , ("M-s"                    , spawn "maim -s | xclip -selection clipboard -t image/png")
    , ("M-S-s"                  , spawn "peek")
    , ("M-<U>"                  , adjustBrightness 0.05)
    , ("M-<D>"                  , adjustBrightness (-0.05))
    , ("M-S-e"                  , spawn fileBrowser)
    , ("M-S-f"                  , sendMessage (Toggle FULL) >> sendMessage ToggleStruts)
    , ("M-f"                    , sendMessage $ Toggle TABBED)
    , ("<XF86AudioRaiseVolume>" , adjustVolume (5))
    , ("<XF86AudioLowerVolume>" , adjustVolume (-5))
    , ("M-S-p"                  , powerPrompt)
    , ("M-p"                    , windows copyToAll) -- Pin to all workspaces
    , ("M-S-a"                  , killAllOtherCopies) -- remove window from all but current
    , ("M-S-l"                  , spawn "i3lock 5 3") -- lock screen
    , ("M-m"                    , activateScratchpad "music")
    , ("M-c"                    , activateScratchpad "ghci")
    , ("M-<Tab>"                , activatePreviousScratchpad)
    , ("M-a"                    , switchAudioInput)
    ] ++ map (workspaceBinding 0) [1..7] ++ map (workspaceBinding 1) [8..9]
    where workspaceBinding screenId ws =
            let id = show ws
            in ("M-" ++ id, windows $ viewOnScreen screenId id)

-- Window rules
rectCentered :: Rational -> W.RationalRect
rectCentered percentage = W.RationalRect offset offset percentage percentage
  where
    offset = (1 - percentage) / 2

myScratchpads =
  [ NSP.NS "music" "alacritty --title music -e ncmpcpp" (title =? "music") $ NSP.customFloating (rectCentered 0.4)
  , NSP.NS "ghci" "alacritty --title ghci -e ghci" (title =? "ghci") $ NSP.customFloating (rectCentered 0.4)
  ]

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , className =? "Peek" --> doFloat
    , className =? "Yad"  --> doCenterFloat
    , isFullscreen        --> doFullFloat
    , isDialog            --> doFloat
    ] <+> NSP.namedScratchpadManageHook myScratchpads

myStartupHook = do
  spawnOnce "xrandr --output DP-2 --primary --mode 2560x1440 -r 165 && xrandr --output HDMI-2 --mode 1920x1080 -r 165 --left-of DP-2 --rotate right"
  spawnOnce "feh --bg-center /home/aidan/images/background/the-savage-state-1440p.png /home/aidan/images/background/savage-state-smol.jpg" -- background
  spawnOnce "xsetroot -cursor_name Quintom_Ink" -- set cursor theme
  spawnOnce "xset r rate 250 50"
  -- Fixes `xdg-open`. See here:
  --  https://www.reddit.com/r/NixOS/comments/193hk48/comment/khbtfy9/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  spawnOnce "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"
  setWMName "LG3D"

data TABBED = TABBED deriving (Read, Show, Eq, Typeable)

instance Transformer TABBED Window where
    transform _ x k = k (tabbed shrinkText tabCfg) (const x)
      where
        tabCfg = def { activeColor = bg
                     , inactiveColor = fg
                     , activeTextColor = fg
                     , inactiveTextColor = bg
                     , activeBorderColor = ""
                     , inactiveBorderColor = ""
                     , fontName = "xft:Iosevka:size=12"
                     , decoHeight = 32}

myLayout =
  avoidStruts
  . mkToggle (single FULL)
  . mkToggle (single TABBED)
  . smartBorders
  . spacingWithEdge 6
  $ named "1/2" (Tall 1 (3/100) (1/2))
  ||| named "2/3" (Tall 1 (3/100) (2/3))
  ||| named "float" simpleFloat

sep = xmobarColor fgDim "" " // "

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = sep
    , ppVisible         = (ppColor fgDim) . wrap " " " "
    , ppCurrent         = (ppColor fg) . wrap ("<box type=Bottom width=2 mb=2 color=" ++ hl ++ "> ") " </box>"
    , ppHidden          = (ppColor fgDim) . wrap " " " "
    , ppLayout          = (ppColor fg)
    , ppOrder           = \[ws,layout,_] -> [ws,layout]
    }
  where
    ppColor :: String -> String -> String
    ppColor c = xmobarColor c ""
