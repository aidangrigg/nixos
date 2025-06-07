{ pkgs, ... }: {
  home.packages = with pkgs; [
    ed-odyssey-materials-helper
    edmarketconnector
  ];
}
