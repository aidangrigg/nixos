{ pkgs, ... }: {
  home.packages = with pkgs; [
    libresprite
    unityhub
  ];
}
