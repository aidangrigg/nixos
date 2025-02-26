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
    inactiveOpacity = 0.9;
    activeOpacity = 1;
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
