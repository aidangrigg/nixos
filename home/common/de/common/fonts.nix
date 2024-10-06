{ pkgs, ... }: {
  home.packages = with pkgs; [ 
    roboto-mono
  ];
  fonts.fontconfig.enable = true;
}

