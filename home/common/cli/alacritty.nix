{ ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "Iosevka";
        };
        size = 14;
      };
      window.padding = {
        x = 5;
        y = 5;
      };
      colors.primary = {
        background = "#000000";
        foreground = "#FFFFFF";
      };
    };
  };
}
