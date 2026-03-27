{pkgs, ...}: {
  # bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      nix_prompt() {
        if [[ -n "$IN_NIX_SHELL" ]]; then
          printf "[%s] " "''${NIX_SHELL_NAME:-nix-develop}"
        fi
      }

      export PS1='\w $(nix_prompt)$(__git_ps1 "(%s) ")$ '
    '';

    shellAliases = {
      hms = "home-manager switch --flake ~/nix/#desktop";
      nrs = "sudo nixos-rebuild switch --flake ~/nix#desktop";
      del = "${pkgs.trash-cli}/bin/trash";
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # direnv (for bash)
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
