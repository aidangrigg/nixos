{ pkgs, config, ... }: let
  nixDir = "${config.home.homeDirectory}/nix/home/common/emacs";
in {
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.treesit-grammars.with-all-grammars # treesitter

      (epkgs.trivialBuild {
        pname = "org-timed-alerts";
        version = "N/A";
        src = pkgs.fetchFromGitHub {
          owner = "legalnonsense";
          repo = "org-timed-alerts";
          rev = "ba499f4471800754c75657d92c3150cb0b5deea2";
          hash = "sha256-KznWuL8O6IicR+dbm5Q/RQPtBFZaWrapvklXvDZRodw=";
        };
        packageRequires = [ epkgs.ts epkgs.alert epkgs.org-ql ];
      })

      epkgs.org-super-agenda                   # better org agenda
      epkgs.org-ql                             # org agenda query language
      epkgs.alert                              # alerts
      epkgs.org-download                       # copy paste images into org buffers
      epkgs.org-roam                           # zettelkasten notetaking
      epkgs.org-roam-ui                        # cool ui for larping
      epkgs.org-appear                         # show/hide org formatting characters

      epkgs.ef-themes # themes

      epkgs.elfeed                             # rss
      epkgs.olivetti                           # center align buffers
      epkgs.citar                              # citations
      epkgs.auctex                             # latex

      epkgs.popper                             # popup buffers
      epkgs.hydra                              # group bindings
      epkgs.surround                           # surround
      epkgs.multiple-cursors                   # what it sounds like
      epkgs.meow                               # modal editing

      epkgs.f # helper for files

      epkgs.rg                                 # ripgrep
      epkgs.vertico                            # vertical completion
      epkgs.marginalia                         # annotations for completions
      epkgs.orderless                          # idk
      epkgs.consult                            # tbh a lot of stuff
      epkgs.embark                             # context menu
      epkgs.embark-consult                     # embark consult support

      epkgs.yasnippet                          # snippets
      epkgs.eldoc-box                          # popup for eldoc
      epkgs.corfu                              # completion
      epkgs.cape                               # not really sure, completion related

      epkgs.direnv                             # direnv
      epkgs.magit # git

      epkgs.haskell-mode
      epkgs.csv-mode
      epkgs.nix-mode
      epkgs.markdown-mode
      epkgs.glsl-mode
      epkgs.gdscript-mode
      epkgs.zig-mode
      epkgs.tuareg
      epkgs.protobuf-mode
    ];
  };

  services.emacs = {
    enable = true;
    defaultEditor = true;
    client.enable = true;
  };

  home.file = {
    ".emacs.d/init.el".source = config.lib.file.mkOutOfStoreSymlink "${nixDir}/cfg/init.el";
    ".emacs.d/snippets".source = config.lib.file.mkOutOfStoreSymlink "${nixDir}/cfg/snippets/";
    ".emacs.d/modules".source = config.lib.file.mkOutOfStoreSymlink "${nixDir}/cfg/modules/";
  };
}
