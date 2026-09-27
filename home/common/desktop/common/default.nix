{ pkgs, ... }: {
  imports = [
    ./user-dirs.nix
    ./fonts.nix
    ./pdf.nix
    ./gtk.nix
    ./web-browser.nix
    ./easyeffects.nix
  ];

  programs.obs-studio.enable = true;
  home.packages = with pkgs; [
    nemo
  ];
}
