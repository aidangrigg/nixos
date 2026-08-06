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

      # https://evanhahn.com/scripts-i-wrote-that-i-use-all-the-time/
      boop() {
        local last="$?"

        if [[ "$last" -eq 0 ]]; then
           sfx good
        else
           sfx bad
        fi

        $(exit "$last")
      }

      export PS1='\w $(nix_prompt)$(__git_ps1 "(%s) ")$ '
    '';

    shellAliases = {
      hms = "home-manager switch --flake ~/nix/#$(hostname)";
      nrs = "sudo nixos-rebuild switch --flake ~/nix#$(hostname)";
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
