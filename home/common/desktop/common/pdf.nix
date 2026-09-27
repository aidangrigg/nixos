{ pkgs, pkgs-unstable, ... }: {
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
    pdfpc
    xournalpp
    poppler-utils # pdftotext
  ];
}
