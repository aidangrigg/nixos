{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common/emacs
    ./common/de/xmonad
    ./common/cli
    ./common/productivity
    ./common/productivity/qutebrowser.nix
  ];

  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "aidan";
    homeDirectory = "/home/aidan";
  };

  gtk.gtk4.theme = config.gtk.theme;

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    theme = {
      name = "Adwaita";
    };
  };

  home.packages = with pkgs; [
    # browsers
    firefox
    chromium

    file
    zip
    unzip
    ffmpeg

    pavucontrol
    vlc
    mpv

    inkscape
    gimp

    nemo

    ghc
    ghcid

    qmk
  ];

  programs.bashmount.enable = true;
  programs.obs-studio.enable = true;

  programs.home-manager.enable = true;
  programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
