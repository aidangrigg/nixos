{ pkgs, config, ... }: let
  dir = "/home/aidan/nix/home/common/emacs";
in {
  programs.emacs = {
    enable = true;
    extraPackages = (epkgs: [ epkgs.treesit-grammars.with-all-grammars ]);
  };

  services.emacs.enable = true;

  home.file = {
    ".emacs.d/init.el".source = config.lib.file.mkOutOfStoreSymlink "${dir}/cfg/init.el";
    ".emacs.d/snippets".source = config.lib.file.mkOutOfStoreSymlink "${dir}/cfg/snippets/";
  };
}
