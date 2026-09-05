{ pkgs, pkgs-unstable, lib, ... }: {
  home.packages =
    let
      dmenu = (pkgs.writeShellApplication {
        name = "dmenu.sh";
        runtimeInputs = with pkgs; [];
        text = lib.readFile ./src/dmenu.sh;
      });
      sfx = (pkgs.writeShellApplication {
        name = "sfx";
        runtimeInputs = with pkgs; [ pkgs.mpv ];
        text = lib.readFile ./src/sfx;
      });
    in [
      dmenu
      sfx
      (pkgs.writeShellApplication {
        name = "dmenu-powermenu";
        runtimeInputs = [dmenu pkgs.xsecurelock];
        text = lib.readFile ./src/dmenu-powermenu.sh;
      })
      (pkgs.writeShellApplication {
        name = "copy";
        runtimeInputs = [ pkgs.xclip ];
        text = lib.readFile ./src/copy;
      })
      (pkgs.writeShellApplication {
        name = "pasta";
        runtimeInputs = [ pkgs.xclip ];
        text = lib.readFile ./src/pasta;
      })
      (pkgs.writeShellApplication {
        name = "getalbum";
        runtimeInputs = [ pkgs-unstable.yt-dlp pkgs.beets ];
        text = lib.readFile ./src/getalbum;
      })
      (pkgs.writeShellApplication {
        name = "dmenu-nix";
        runtimeInputs = [];
        text = lib.readFile ./src/dmenu-nix.sh;
      })

  ];
}
