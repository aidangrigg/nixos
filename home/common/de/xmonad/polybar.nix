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
        
        fixed-center = true;
        modules-left = "xworkspaces";
        modules-center = "date";
        modules-right = "tray";
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
        label = "%date% | %time%";
        date = "%Y-%m-%d%";
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
    };
  };
}
