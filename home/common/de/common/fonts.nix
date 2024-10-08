{ pkgs, ... }: {
  home.packages = with pkgs; [ 
    roboto-mono
    font-awesome
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  fonts.fontconfig.enable = true;
}

