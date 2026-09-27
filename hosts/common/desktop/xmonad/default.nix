{ pkgs, lib, config, ... }:
{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };

    autoRepeatDelay = 250;
    autoRepeatInterval = 50;

    displayManager.lightdm.enable = true;

    windowManager.xmonad = {
      enable = true;
    };
  };

  services.displayManager.defaultSession = "none+xmonad";

  environment.systemPackages = (with pkgs; [
    lxqt.lxqt-policykit
  ]);
}
