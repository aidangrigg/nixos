# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # FIXME: Add the rest of your current configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # internet
  networking = {
    hostName = "nixos-desktop";
    networkmanager.enable = true;
  };

  # enable logitech mouse configuration
  services.ratbagd.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  programs.nh = {
    enable = true;
  };

  # audio
  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes
  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  time.timeZone = "Australia/Sydney";

  # steam
  programs.steam.enable = true;
  programs.nix-ld.enable = true;

  # keyboard
  hardware.keyboard.qmk.enable = true;

  # flatpak
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

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

  programs.adb.enable = true;
  services.atd.enable = true;

  users.users = {
    aidan = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "docker"];
      packages = with pkgs; [
        xkbset
      ];
    };
  };

  # wm and dm
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
    #   enableContribAndExtras = true;
    };
  };

  services.speechd.enable = false;

  # screen lock
  programs.i3lock = {
    enable = true;
    package = pkgs.i3lock-fancy-rapid;
  };

  services.displayManager.defaultSession = "none+xmonad";
  programs.dconf.enable = true;

  services.libinput.mouse.accelProfile = "flat";

  programs.git = {
    enable = true;
    prompt.enable = true;
  };

  # udev rules
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

  # virtualisation
  virtualisation = {
    containers.enable = true;
    docker.enable = true;
  };


  # Set up virtualisation
  virtualisation.libvirtd = {
    enable = true;

    # Enable TPM emulation (for Windows 11)
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf = {
        enable = true;
        packages = [pkgs.OVMFFull.fd];
      };
      swtpm.enable = true;
    };
  };

  # Enable USB redirection
  virtualisation.spiceUSBRedirection.enable = true;

  # Allow VM management
  users.groups.libvirtd.members = [ "aidan" ];
  users.groups.kvm.members = [ "aidan" ];

  # if you use libvirtd on a desktop environment
  programs.virt-manager.enable = true; # can be used to manage non-local hosts as well

  services.gvfs.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    # allowedUDPPortRanges = [
    #   { from = 16571; to = 16604; }
    # ];
    # allowedTCPPortRanges = [
    #   { from = 16572; to = 16604; }
    # ];
  };

  # services.tailscale.enable = true;

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # services.influxdb2.enable = true;
  # services.grafana = {
  #   enable = true;
  #   settings = {
  #     server = {
  #       # Listening Address
  #       http_addr = "0.0.0.0";
  #       # and Port
  #       http_port = 3000;
  #     };
  #   };
  # };

  environment.systemPackages = (with pkgs; [
    git
    htop
    vim
    wget
    which
    blender-hip
  ]);

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
