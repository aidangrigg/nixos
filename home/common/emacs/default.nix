{ pkgs, ... }: let
  emacsPkg = pkgs.emacs;
  in {
    services.emacs = {
      enable = true;
      package = emacsPkg;
    };

    programs.emacs = {
      enable = true;
      package = emacsPkg;
    };

    xresources.properties = {
      "Xft.autohint" = 1;
      "Xft.antialias" = 1;
      "Xft.hinting" = 1;
      "Xft.hintstyle" = "hintslight";
      "Xft.dpi" = 96;
      "Xft.rgba" = "rgb";
      "Xft.lcdfilter" = "lcddefault";
    };
}
