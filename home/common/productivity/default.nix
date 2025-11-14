{ pkgs, ... }: {
  imports = [ ./latex.nix ];

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
    };
  };

  xdg.desktopEntries = {
    zathura = {
      name = "Zathura";
      genericName = "pdf viewer";
      exec = "zathura %U";
      terminal = false;
    };
  };

  home.packages = with pkgs; [
    xournalpp
    hunspell
    hunspellDicts.en_AU
    pdfpc
    libreoffice
    zotero
    plantuml
    anki-bin
  ];
}
