{ pkgs, lib, config, ... }:
{
  services.lact.enable = true;
  environment.systemPackages = with pkgs; [
    lact
    btop-rocm
  ];
}
