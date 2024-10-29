{ pkgs, ... }: {
  imports = [ ./latex.nix ];

  programs.zathura.enable = true;

  home.packages = with pkgs; [
    xournalpp
    hunspell
    hunspellDicts.en_AU
    pdfpc
  ];
}
