{ pkgs, ... }: {
  imports = [
    ./bash.nix
    ./alacritty.nix
    ./scripts/default.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    fzf
    fd
    jq
    htop
    helix
    wget
    vim
    xclip
    tmux
    trash-cli
  ];
}
