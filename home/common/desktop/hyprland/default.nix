{ pkgs, config, ... }: {
  imports = [
    ./../common
  ];

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.packages = with pkgs; [
    rofi
    libnotify
    grim
    slurp
    wl-clipboard
  ];

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Iosevka:size=12";
        pad = "2x2";
      };

      colors = {
        background = "120e08";
        foreground = "b3976d";
         # [colors.normal];
        regular0 = "120e08";
        regular1 = "b3976d";
        regular2 = "b3976d";
        regular3 = "8c734e";
        regular4 = "8c734e";
        regular5 = "b3976d";
        regular6 = "8c734e";
        regular7 = "655030";
         # [colors.bright];
        bright0 = "231b0e";
        bright1 = "d1b994";
        bright2 = "d1b994";
        bright3 = "b3976d";
        bright4 = "b3976d";
        bright5 = "d1b994";
        bright6 = "b3976d";
        bright7 = "8c734e";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      actions = true;
      anchor = "top-right";
      background-color = "#120e08";
      border-color = "#b3976d";
      border-radius = 0;
      default-timeout = 0;
      font = "Iosevka 10";
      height = 100;
      width = 300;
      icons = true;
      ignore-timeout = false;
      layer = "top";
      margin = 12;
      markup = true;

      "app-name=\"Info\"" = {
        anchor = "top-center";
        history = 0;
        group-by = "app-name";
        format = "%b";
      };

      "app-name=\"wp-vol\"" = {
        layer = "overlay";
        history = 0;
        anchor = "bottom-center";
        group-by = "app-name";
        format = "<b>%s</b>\\n%b";
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        output = [
          "DP-2"
        ];
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = ["hyprland/window"];
        modules-right = [
          "tray"
          "network"
          "pulseaudio"
          "clock"
        ];

        tray = {
          spacing = 10;
          tooltip = false;
        };

        network = {
            format-wifi  = "wifi up";
            format-ethernet = "ethernet up";
            format-disconnected  = "no network";
            tooltip = false;
        };

        pulseaudio = {
            scroll-step = 5;
            max-volume = 150;
            format = "vol {volume}%";
            format-bluetooth = "vol {volume}%";
            nospacing = 1;
            on-click = "pavucontrol";
            tooltip = false;
        };

        clock = {
          format = "{:%A, %d/%m/%y [%H:%M]}";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: "Iosevka";
          font-weight: bold;
          font-size: 14px;
          padding: 0;
      }

      window#waybar {
          background: #120e08;
          border: 1px solid #b3976d;
      }

      #clock, #pulseaudio, #network, #tray, #battery {
          margin: 8px 8px 8px 0px;
          padding: 2px 8px 2px 8px;
          color: #1b140a;
          background-color: #b3976d;
          border: 2px solid #8c734e;
      }

      #workspaces {
          margin: 8px 0px 8px 16px;
      }

      #workspaces button {
          all: initial;
          padding: 2px 8px 2px 0px;
          color: #8c734e;
      }

      #workspaces button.active {
          color: #d1b994;
      }

      #workspaces button.urgent,
      #battery.warning, #battery.critical, #battery.urgent {
          background-color: #b3976d;
          padding: 2px 8px;
          color: #120e08;
      }
  '';
  };

  # services.hyprsunset = {
  #   enable = true;
  #   transitions = {
  #     sunrise = {
  #       calendar = "*-*-* 06:00:00";
  #       requests = [
  #         [ "temperature" "6500" ]
  #         [ "gamma 100" ]
  #       ];
  #     };
  #     sunset = {
  #       calendar = "*-*-* 19:00:00";
  #       requests = [
  #         [ "temperature" "3500" ]
  #         [ "gamma 60" ]
  #       ];
  #     };
  #   };
  # };

  services.hyprpaper.enable = true;

	home.file = {
    # ".config/hypr/general.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/hypr/general.conf";
    # ".config/hypr/hyprbar.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/hypr/hyprbar.conf";
    # ".config/hypr/hyprsunset.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/hypr/hyprsunset.conf";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    plugins = with pkgs.hyprlandPlugins; [
      hyprbars
    ];

    extraConfig = ''
       exec-once = waybar
       exec-once = ${pkgs.hyprsunset}/bin/hyprsunset
       source = ~/.config/hypr/general.conf
       source = ~/.config/hypr/hyprbar.conf
    '';
  };
}
