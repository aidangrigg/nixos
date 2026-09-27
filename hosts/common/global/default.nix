{ pkgs, lib, inputs, config, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      nix-path = config.nix.nixPath;
    };
    channel.enable = false;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.libinput.mouse.accelProfile = "flat";

  services.udev = let
    ps4-controller-udev-rules = pkgs.writeTextFile {
      name = "72-ps4touchpad.rules";
      text = ''
        # Disable PS4 touchpad acting as mouse
        # USB
        ATTRS{name}=="Sony Computer Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '';
      destination = "/etc/udev/rules.d/72-ps4touchpad.rules";
    };
  in {
    enable = true;
    packages = with pkgs; [
      usb-blaster-udev-rules
      ps4-controller-udev-rules
    ];
  };

  networking.firewall.enable = true;

  time.timeZone = "Australia/Sydney";
  i18n = {
    defaultLocale = "en_AU.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };
  };

  programs.git = {
    enable = true;
    prompt.enable = true;
  };

}
