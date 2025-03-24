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
    pulseaudio
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
    inactiveOpacity = 0.8;
    activeOpacity = 0.95;
    opacityRules = [
      "100:fullscreen"
    ];
    backend = "glx";
    settings = {
      blur = {
        method = "dual_kawase";
        strength = 6;
      };
      blur-background-exclude = [
        "class_g = 'slop'"
      ];
    };
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
        font = "GohuFont 10";
      };
    };
  };
}
