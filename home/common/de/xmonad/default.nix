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

    xsecurelock
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
             , additionalFonts = ["Siji 8", "DotGothic16"]
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
        idle_threshold = "5s";

        follow = "mouse";
        geometry = "300x60-20+48";

        indicate_hidden = "yes";
        shrink = "no";
        separator_height = 0;
        padding = 32;
        horizontal_padding = 32;
        frame_width = 2;
        line_height = 4;

        markup = "full";
        format = "%s\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = "yes";
        show_indicators = "no";
        icon_position = "left";
        sticky_history = "yes";
        history_length = 20;

        frame_color = "#1a1a1a";
        background = "#1a1a1a";
        foreground = "#e0e0e0";
        highlight = "#e0e0e0";
        font = "Terminus 8";
      };

    };
  };
}
