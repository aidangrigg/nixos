{ pkgs, config, ... }: let
  nixDir = "${config.home.homeDirectory}/nix/home/common/emacs";
in {
  programs.emacs = {
    enable = true;
    extraPackages = (epkgs: [ epkgs.treesit-grammars.with-all-grammars ]);
  };

  services.emacs = {
    enable = true;
    defaultEditor = true;
    client.enable = true;
  };

  home.file = {
    ".emacs.d/init.el".source = config.lib.file.mkOutOfStoreSymlink "${nixDir}/cfg/init.el";
    ".emacs.d/snippets".source = config.lib.file.mkOutOfStoreSymlink "${nixDir}/cfg/snippets/";
  };
}
