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

  programs.i3lock.enable = true;

  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.i3lock}/bin/i3lock -c 000000";
  };

  services.displayManager.defaultSession = "none+xmonad";

  environment.systemPackages = (with pkgs; [
    lxqt.lxqt-policykit
  ]);
}
