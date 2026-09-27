{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    ./common/global
    ./common/cli

    # ./common/emacs
    # ./common/de/xmonad
    # ./common/syncthing
    # ./common/productivity
    # ./common/modelling
    # ./common/music
    # ./common/gaming
    # ./common/productivity/qutebrowser.nix
    # ./common/productivity/latex.nix
    # ./common/productivity/gamedev.nix
  ];

  home = {
    username = "aidan";
    homeDirectory = "/home/aidan";
  };

  # # Enable home-manager and git
  # programs.home-manager.enable = true;
  # programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
