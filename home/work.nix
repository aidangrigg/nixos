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
    claude-code
  ];
}
