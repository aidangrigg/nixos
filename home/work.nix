{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    ./common/global
    ./common/cli
  ];

  home = {
    username = "work";
    homeDirectory = "/home/work";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
