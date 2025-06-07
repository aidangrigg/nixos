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

    xdotool
  ];

  xsession.windowManager.xmonad = {
    enable = true;
    config = ./xmonad.hs;
    extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
    ];
  };

  services.picom = {
    enable = true;
    vSync = true; # all my homies hate screen tearing
  };

   programs.xmobar = {
    enable = true;
    extraConfig = ''
Config { overrideRedirect = False
       , font     = "Terminus 8"
       , bgColor  =     "#222222"
       , fgColor  =     "#555555" 
       , position = TopH 31
       , textOffset = 0
       , commands =
         [ Run Date "<fc=white>%A, %d/%m/%y [%H:%M]</fc>" "date" 10
         , Run UnsafeXMonadLog
         ]
        , sepChar  = "%"
        , alignSep = "}{"
        , template = "  %UnsafeXMonadLog% }%date%{"
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
        background = "#222222";
        foreground = "#FFFFFF";
        font = "Terminus 8";
      };
    };
  };
}
