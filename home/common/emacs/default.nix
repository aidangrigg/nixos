{ pkgs, config, ... }: let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
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
    ".emacs.d/init.el".source = mkSymlink "${nixDir}/cfg/init.el";
    ".emacs.d/snippets".source = mkSymlink "${nixDir}/cfg/snippets/";
  };
}
