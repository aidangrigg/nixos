{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/pipewire.nix
    ../common/syncthing.nix
    ../common/global
    ../common/desktop/xmonad
    ../common/vm

    ../common/hardware/amd.nix
    ../common/hardware/qmk.nix
    ../common/hardware/cups.nix
    ../common/hardware/logitech.nix
    ../common/hardware/wireless.nix

    ../common/users/aidan
    ../common/users/work
  ];

  networking = {
    hostName = "malzeno";
    networkmanager = {
      enable = true;
    };
    firewall = {
      allowedTCPPorts = [ 25565 ];
      allowedUDPPorts = [ ];
    };
  };
  services.tailscale.enable = true;

  # steam
  programs.steam.enable = true;
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = (with pkgs; [
    htop
    vim
    wget
    which
    borgbackup
  ]);

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
