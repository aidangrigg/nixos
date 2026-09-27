{ pkgs, config, ... }: {
  programs.qutebrowser.enable = true;
  programs.firefox.enable = true;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
  programs.chromium.enable = true;
}
