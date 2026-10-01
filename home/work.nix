{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    ./common/global
    ./common/cli
  ];

  home = {
    username = "work";
    homeDirectory = "/home/work";
  };

  home.packages = with pkgs; [
    openfortivpn
    slack
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
