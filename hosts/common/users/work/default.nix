{ lib, config, pkgs, ... }: {
  users.users.work = {
    isNormalUser = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = []; # TODO
    extraGroups = [ "wheel" "networkmanager" "dialout" "docker" ];
    packages = with pkgs; []; # TODO
  };
}
