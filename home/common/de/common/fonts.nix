{ pkgs, ... }: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    font-awesome
    roboto
    roboto-mono
    iosevka-bin
    (iosevka-bin.override { variant = "Aile"; })
    terminus_font
    siji
  ];
  fonts.fontconfig.enable = true;
}

