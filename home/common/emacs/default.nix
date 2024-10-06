{ pkgs, ... }: let 
  emacsPkg = pkgs.emacs;
  in {

    services.emacs = {
      enable = true;
      package = emacsPkg;
    };

    programs.emacs = {
      enable = true;
      package = emacsPkg;
    };
}
