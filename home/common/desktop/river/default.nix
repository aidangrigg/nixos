{ pkgs, config, ... }:
let
  dir = "/home/aidan/nix/home/common/de/river";
in {
  imports = [
    ./../common
    ./waybar
  ];

  home.packages = with pkgs; [
    fuzzel
    libnotify
    bc
    wl-clipboard
    brightnessctl
    swaybg
  ];

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Iosevka:size=12";
        pad = "2x2";
      };

      colors = {
        background= "ffffff";
        foreground= "000000";
        regular0="ffffff";
        regular1="af0000";
        regular2="008700";
        regular3="5f8700";
        regular4="0087af";
        regular5="878787";
        regular6="005f87";
        regular7="764e37";
        bright0="bcbcbc";
        bright1="d70000";
        bright2="d70087";
        bright3="8700af";
        bright4="d75f00";
        bright5="d75f00";
        bright6="4c7a5d";
        bright7="005faf";
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
      background-color = "#000000";
      border-color = "#FFFFFF";
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

  home.file = {
    ".config/river".source = config.lib.file.mkOutOfStoreSymlink "${dir}/cfg/river";
  };
}
