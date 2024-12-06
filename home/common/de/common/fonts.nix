{ pkgs, ... }: {
  home.packages = with pkgs; [ 
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    font-awesome
    gohufont
    roboto
    roboto-mono
  ];
  fonts.fontconfig.enable = true;
}

