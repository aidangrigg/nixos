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
             , font            = "Iosevka 10"
             , additionalFonts = ["Siji 8"]
             , textOffsets     = [1]
             , bgColor         = "#fff5ea"
             , fgColor         = "#1c0810"
             , position        = BottomH 32
             , textOffset      = 0
             , commands =
               [ Run Date "%A, %d/%m/%y [%H:%M]" "date" 10
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
