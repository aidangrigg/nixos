{ pkgs, ... }: {
  home.packages = [ pkgs.easyeffects ];
  services.easyeffects.enable = true;
}
