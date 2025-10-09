{ pkgs, config, ... }:
let
  dir = "/home/aidan/nix/home/common/de/river/waybar/";
in {
  programs.waybar = {
    enable = true;
  };

  home.file = {
    ".config/waybar/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${dir}/config.jsonc";
    ".config/waybar/style.css".source = config.lib.file.mkOutOfStoreSymlink "${dir}/style.css";
  };
}
