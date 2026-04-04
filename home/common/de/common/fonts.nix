{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    font-awesome
    roboto
    roboto-mono
    iosevka-bin
    (iosevka-bin.override { variant = "Aile"; })
    etBook
    terminus_font
    siji
    scientifica
  ];
  fonts.fontconfig.enable = true;
}

