{ pkgs, ... }:
let
  colours = {
    background = "#222222";
    foreground = "#FFFFFF";
    foreground-dim = "#AAAAAA";
    midground = "#555555";
  };
in {
  services.polybar = {
    enable = true;
    script = "polybar &";
    settings = {
      "bar/top" = {
        width = "100%";
        height = 28;
        padding = 1;
        border-size = 5;
        border-bottom-size = 0;
        border-color = "#00000000";
        wm-restack = "ewmh";
        bottom = false;
        module-margin = 1;
        enable-ipc = true;
        fixed-center = true;
        modules-left = "xworkspaces";
        modules-center = "date";
        modules-right = "pipewire";
        font-0 = "GohuFont:size=12;2";
        background = colours.background;
        foreground = colours.foreground;
      };
      "module/tray" = {
        type = "internal/tray";
        tray-size = "45%";
      };
      "module/date" = {
        type = "internal/date";
        interval = 1.0;
        label = "%date% [%time%]";
        date = "%A, %d/%m/%Y";
        time = "%H:%M";
      };
      "module/xworkspaces" = {
        type = "internal/xworkspaces";

        label-active = "%name%";
        label-active-padding = 1;
        
        label-occupied = "%name%";
        label-occupied-padding = 1;
        label-occupied-foreground = colours.foreground-dim;
        label-empty = "";
      };
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume = "<label-volume>";
        label-volume = "%percentage%%";
      };
      "module/pipewire" = {
        type = "custom/script";
        label = "VOL: %output%";
        exec = pkgs.writeShellScript "pipewire.sh" ''
          ${pkgs.pamixer}/bin/pamixer --get-volume-human
        '';
      };
      "module/cpu" = {
        type = "internal/cpu";
        label = "%percentage:3%%";
        format = "<label>";
      };
      "module/memory" = {
        type = "internal/memory";
        label = "%gb_used%";
        format = "<label>";
      };
    };
  };
}
