{ pkgs, ... }: {
  home.packages = with pkgs; [ 
    roboto-mono
    font-awesome
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    gohufont
  ];
  fonts.fontconfig.enable = true;
}

