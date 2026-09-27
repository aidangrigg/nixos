{ pkgs, ... }: {
  imports = [
    ./bash.nix
    ./alacritty.nix
    ./scripts
  ];

  programs.bashmount.enable = true;

  home.packages = with pkgs; [
    ghc
    ghcid

    file
    zip
    unzip
    ffmpeg

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
