{ pkgs, ... }: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    font-awesome
    roboto
    roboto-mono
    gohufont
    terminus_font
  ];
  fonts.fontconfig.enable = true;
}

