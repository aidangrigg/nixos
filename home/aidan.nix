{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    ./common/global
    ./common/cli
  ];

  home = {
    username = "aidan";
    homeDirectory = "/home/aidan";
  };

  # # Enable home-manager and git
  # programs.home-manager.enable = true;
  # programs.git.enable = true;
}
