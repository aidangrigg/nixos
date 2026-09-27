{ pkgs, lib, config, ... }: {
  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes
  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
