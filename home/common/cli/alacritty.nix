{ ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "Terminus";
        };
        size = 12;
      };
      window.padding = {
        x = 5;
        y = 5;
      };
      colors.primary = {
        background = "#222222";
        foreground = "#FFFFFF";
      };
    };
  };
}
