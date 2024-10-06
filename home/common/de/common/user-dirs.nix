{ config, ... }: {
  xdg.userDirs = {
    enable = true;
    desktop = "${config.home.homeDirectory}/desktop";
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/media/music";
    videos = "${config.home.homeDirectory}/media/videos";
    pictures = "${config.home.homeDirectory}/images";
  };
}
