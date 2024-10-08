{
  # bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      export PS1='\w $(__git_ps1 "(%s) ")$ '
    '';

    shellAliases = {
      hms = "home-manager switch --flake ~/nix/#desktop";
      nrs = "sudo nixos-rebuild switch --flake ~/nix#desktop";
    };
  };

  # direnv (for bash)
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
