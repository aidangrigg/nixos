{ pkgs, ... }: {
  imports = [
    ./../common
    ./polybar.nix
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
  ];

  xsession.windowManager.xmonad = {
    enable = true;
    config = ./xmonad.hs;
    extraPackages = hpkgs: [
      hpkgs.xmonad-contrib
    ];
  };

  services.picom = {
    enable = true;
    vSync = true; # all my homies hate screen tearing
    inactiveOpacity = 0.9;
    activeOpacity = 1;
  };

  services.dunst = {
    enable = true;
  };

#   programs.xmobar = {
#     enable = true;
#     extraConfig = ''
# Config { overrideRedirect = False
#        , font     = "GohuFont 10"
#        , bgColor  =     "#222222"
#        , fgColor  =     "#555555" 
#        , position = TopH 25
#        , commands =
#          [ Run MultiCpu      [ "--template", "<fc=white>[C] <total>%</fc>" ] 30
#          , Run Memory        [ "--template", "<fc=white>[R] <used>M</fc>" ] 30
#          , Run MultiCoreTemp [ "--template", "<fc=white><max>°C</fc>" ] 30
# 	       , Run DiskU         [("/", "<fc=white>[D] <free></fc>")] [] 2400
#          , Run Date          "<fc=white>%H:%M %a %b %d, %Y</fc>" "date" 10
#          , Run XMonadLog
#          ]
#         , sepChar  = "%"
#         , alignSep = "}{"
#         , template = " %XMonadLog% }{ %multicpu% %multicoretemp% // %memory% // %disku% // %date% "
#         }
#     '';
  # };
}
