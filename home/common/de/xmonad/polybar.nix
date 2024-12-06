{ ... }:
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
        padding = 1;
        height = 32;

        module-margin = 1;
        enable-ipc = true;
        fixed-center = true;
        modules-left = "xworkspaces";
        modules-center = "date";
        modules-right = "tray memory cpu";
        font-0 = "Roboto Mono:size=10;2";
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
        label = "%date% %time%";
        date = "%Y-%m-%d (%a)";
        time = "%r";
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
