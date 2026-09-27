{ pkgs, config, ... }: {
  gtk.gtk4.theme = config.gtk.theme;

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    theme = {
      name = "Adwaita";
    };
  };
}
