{ pkgs, ... }: {
  imports = [
    ./bash.nix
    ./alacritty.nix
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
    tmux
  ];
}
