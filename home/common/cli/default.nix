{ pkgs, ... }: {
  imports = [
    ./bash.nix
  ];
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    htop
    helix
    wget
    vim
    xclip
  ];
}
