{ pkgs, lib, nixpkgs, ... }: {
  home.packages = with pkgs; [
    autorandr
  ];

  services.autorandr.enable = true;

  programs.autorandr = {
    enable = true;
    profiles = {
      laptop = {
        config = {
          "eDP-1" = {
            enable = true;
            mode = "1920x1080";
            primary = true;
            position = "0x0";
            rate = "60.00";
          };
        };

        fingerprint = {
          "eDP-1" = "00ffffffffffff0030e4210500000000001a0104951f1178ea9d35945c558f291e5054000000010101010101010101010101010101012e3680a070381f403020350035ae1000001a542b80a070381f403020350035ae1000001a000000fe004c4720446973706c61790a2020000000fe004c503134305746362d535042340077";
        };

        hooks.postswitch = ''
          feh --bg-center /home/aidan/nix/assets/backgrounds/savage-state-horizontal.png
        '';
      };

      desktop = {
        config = {

        };

        fingerprint = {

        };
      };
    };
  };
}
