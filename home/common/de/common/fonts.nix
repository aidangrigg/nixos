{ pkgs, ... }: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    font-awesome
    roboto
    roboto-mono
    iosevka
    terminus_font
    siji
  ];
  fonts.fontconfig.enable = true;
}

