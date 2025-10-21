{ pkgs, ... }: {
  imports = [ ./latex.nix ];

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
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
  ];
}
