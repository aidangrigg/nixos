{ pkgs, config, ... }: let
  dir = "/home/aidan/nix/home/common/emacs";
  # pkg = emacsWithPackages (ps: with ps; [ tree-sitter-langs treesit-grammars.with-all-grammars ]);
in {
  programs.emacs = {
    enable = true;
    extraPackages = (epkgs: [ epkgs.treesit-grammars.with-all-grammars ]);
  };

  home.file = {
    ".emacs.d/init.el".source = config.lib.file.mkOutOfStoreSymlink "${dir}/cfg/init.el";
    ".emacs.d/snippets".source = config.lib.file.mkOutOfStoreSymlink "${dir}/cfg/snippets/";
  };
}
