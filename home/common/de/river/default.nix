{ pkgs, config, ... }:
let
  dir = "/home/aidan/nix/home/common/de/river";
in {
  imports = [
    ./../common
  ];

  home.packages = with pkgs; [
    fuzzel
    libnotify
    bc
    wl-clipboard
    brightnessctl
    swaybg
  ];

  programs.foot.enable = true;
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
