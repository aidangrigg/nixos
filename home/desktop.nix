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
    ./common/de/xmonad
    ./common/cli
    ./common/syncthing
    ./common/productivity
    ./common/modelling
    ./common/music
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

  home.pointerCursor = {
    name = "Quintom_Ink";
    package = pkgs.quintom-cursor-theme;
    gtk.enable = true;
    x11.enable = true;
    size = 12;
  };

  specialisation.dark.configuration = {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
      };
    };
  };

  specialisation.light.configuration = {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-light";
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-light";
      };
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

    remmina

    xorg.xhost

    qmk

    prismlauncher
    mangohud
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
