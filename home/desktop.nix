# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./common/emacs
    # ./common/de/hyprland
    ./common/de/xmonad
    ./common/cli
    ./common/syncthing
    ./common/productivity
    ./common/modelling
    ./common/music
    ./common/gaming
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
    peek

    inkscape
    gimp

    nemo

    ghc
    ghcid

    piper

    xorg.xhost

    qmk

    prismlauncher
    mangohud

    kdePackages.kdenlive
  ];

  services.emacs.enable = true;

  programs.bashmount.enable = true;
  programs.obs-studio.enable = true;

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
