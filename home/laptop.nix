
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
    ./common/de/river
    ./common/cli
    ./common/syncthing
    ./common/productivity
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
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

  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.vimix-icon-theme;
      name = "Vimix-White";
    };

    theme = {
      package = pkgs.arc-theme;
      name = "Arc-Dark";
    };
  };

  home.packages = with pkgs; [
    # browsers
    firefox
    chromium
    pavucontrol
    mpv
    inkscape
    gimp
    nemo
    zip
    unzip
    remmina
    networkmanagerapplet
    wl-clipboard
  ];

  programs.bashmount.enable = true;
  programs.obs-studio.enable = true;

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
