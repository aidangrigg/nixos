{ ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
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
