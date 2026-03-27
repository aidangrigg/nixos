{ pkgs, ... }: {
  imports = [
    ./../common
    ./../../suckless
  ];

  home.packages = with pkgs; [
    # screenshot util
    maim # png
    peek # gif/mp4

    # background
    feh

    # search
    rofi

    # send notifications from the shell
    libnotify

    # adjust volume
    pamixer
    pulseaudio

    xdotool
  ];

  programs.patched-dmenu.enable = true;
  programs.patched-st.enable = true;

  xsession.windowManager.xmonad = {
    enable = true;
    config = ./xmonad.hs;
    extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
      pkgs.pulseaudio
    ];
  };

  services.picom = {
    enable = true;
    vSync = true; # all my homies hate screen tearing
  };

  programs.xmobar = {
    enable = true;
    extraConfig = let
      music_script = pkgs.writeShellScript "xmobar-mpd" ''
        STATUS=$(${pkgs.mpc}/bin/mpc status | grep -oE '\[(playing|paused)\]')
        if [ $STATUS == "[playing]" ]; then
          # MPD is playing
            echo "<fn=1></fn>$(${pkgs.mpc}/bin/mpc current)"
        fi
      '';
    in ''
    Config { overrideRedirect  = False
             , font            = "Terminus 8"
             , additionalFonts = ["Siji 8"]
             , textOffsets     = [1]
             , bgColor         = "#1a1a1a"
             , fgColor         = "#e0e0e0"
             , position        = Static { xpos = 1210 , ypos = 10, width = 2300, height = 25 }
             , commands =
               [ Run Date "%a %H:%M" "date" 10
               , Run UnsafeXMonadLog
               , Run Com "${music_script}" [] "mpd_script" 10
               , Run Memory [ "-t", "<used>G", "--", "--scale", "1024"] 20
               ]
              , sepChar  = "%"
              , alignSep = "}{"
              , template = "  %UnsafeXMonadLog% }{ %mpd_script%   %memory%   %date%  "
    }
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "top-right";
        frame_color = "#e0e0e0";
        frame_width = 1;
        background = "#1a1a1a";
        foreground = "#e0e0e0";
        font = "Terminus 8";
        idle_threshold = "5s";
      };
    };
  };
}
