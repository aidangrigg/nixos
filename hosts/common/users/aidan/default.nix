{ lib, config, pkgs, ... }: {
  # users.mutableUsers = false; # TODO: set up sops
  users.users.aidan = {
    isNormalUser = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = []; # TODO
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "docker"];
    packages = with pkgs; []; # TODO
  };
}
