{ pkgs, lib, config, ... }: {
  options = {
    programs.patched-dmenu = {
      enable = lib.mkEnableOption "Patched dmenu";
    };
  };

  config = lib.mkIf config.programs.patched-dmenu.enable {
    home.packages = let
      dmenu = pkgs.dmenu.override( { patches = [ ./patches/dmenu-center-20250407-b1e217b.diff ]; } );
    in [
      dmenu
    ];
  };
}
