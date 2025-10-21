{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    osu-lazer-bin
  ];
}
