{ pkgs, ... }: {
  imports = [
    ./../common
    # ./polybar.nix
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

    dmenu

    xdotool
  ];

  xsession.windowManager.xmonad = {
    enable = true;
    config = ./xmonad.hs;
    extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
      pkgs.pulseaudio
    ];
  };

  services.gammastep = {
    enable = false;
    provider = "manual";
    latitude = -34.1;
    longitude = 150.0;
    settings = {
      general = {
        brightness-day = 1.0;
        brightness-night = 0.9;
      };
    };
    temperature.night = 3000;
    temperature.day = 7000;
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
            echo "<fc=white><fn=1></fn>$(${pkgs.mpc}/bin/mpc current)</fc>"
        fi
      '';
    in ''
    Config { overrideRedirect = False
             , font     = "Terminus 8"
             , additionalFonts = ["Siji 8"]
             , textOffsets = [1]
             , bgColor  =     "#222222"
             , fgColor  =     "#555555"
             , position = TopH 31
             , textOffset = 0
             , commands =
               [ Run Date "<fc=white>%A, %d/%m/%y [%H:%M]</fc>" "date" 10
               , Run UnsafeXMonadLog
               , Run Com "${music_script}" [] "mpd_script" 10
               ]
              , sepChar  = "%"
              , alignSep = "}{"
              , template = "  %UnsafeXMonadLog% }%date%{%mpd_script%  "
    }
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "top-right";
        frame_color = "#FFFFFF";
        frame_width = 1;
        background = "#000000";
        foreground = "#FFFFFF";
        font = "Iosevka 10";
        idle_threshold = "5s";
      };
    };
  };
}
