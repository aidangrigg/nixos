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

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # internet
  networking = {
    hostName = "malzeno";
    networkmanager = {
      enable = true;
      dns = "none";
    };
    nameservers = [ "127.0.0.1" "::1" ];
  };

  # dns

  services.dnscrypt-proxy = {
    enable = true;
    # Settings reference:
    # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
    settings = {
      ipv4_servers = true;
      ipv6_servers = true;
      require_dnssec = true;
      # Maximum log files size in MB
      log_files_max_size = 10;
      # Helpful to check if dnscrypt-proxy is actually used
      query_log.file = "/var/log/dnscrypt-proxy/query.log";
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolver/smaster/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      # List chosen from [0]. I only include servers/providers that:
      # - provide DNSSEC and DoH
      # - do no filtering and no logging (at least claim so)
      # - have servers in Europe
      #
      # dnscrypt-proxy will sort this by latency but also rotate the DNS
      # servers to improve privacy.
      # [0] https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      server_names = [
        "quad9-doh-ip4-port443-filter-pri"
        "quad9-doh-ip6-port443-filter-pri"
      ];
    };
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

  # VR

  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  # flatpak
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];

    config.common.default = "*";
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  services.atd.enable = true;

  users.users = {
    aidan = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];

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
    };
  };

  # screen lock
  programs.i3lock.enable = true;
  services.displayManager.defaultSession = "none+xmonad";

  # SDDM Display Manager
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };

  # # # Exclude certain default applications from being installed
  # # environment.plasma6.excludePackages = with pkgs; [ kdePackages.<package> ];

  # programs.hyprland = {
  #   enable = true;
  #   withUWSM = true;
  #   xwayland.enable = true;
  # };

  # services.speechd.enable = false;

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
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ ];
    # allowedUDPPortRanges = [
    #   { from = 16571; to = 16604; }
    # ];
    # allowedTCPPortRanges = [
    #   { from = 16572; to = 16604; }
    # ];
  };

  services.tailscale.enable = true;

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
    btop-rocm
    git
    htop
    vim
    wget
    which
    borgbackup
    lxqt.lxqt-policykit

    lact
  ]);

  services.lact.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
