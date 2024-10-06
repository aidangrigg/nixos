{ pkgs, ... }: {
  home.packages = with pkgs; [ 
    roboto-mono
    font-awesome
  ];
  fonts.fontconfig.enable = true;
}

