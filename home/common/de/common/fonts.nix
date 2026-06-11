{ pkgs, lib, nixpkgs, ... }:
let
  dot-gothic16 = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "dot-gothic";
    version = "1.101";

    src = pkgs.fetchurl {
      url = "https://github.com/fontworks-fonts/DotGothic16/archive/refs/tags/Version1.101.tar.gz";
      hash = "sha256-9OEvpN1ijO/zia75uhXyJ4AqE4Q1aJClSqJb8nPPdvQ=";
    };

    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp -r fonts/ttf/*.ttf $out/share/fonts/truetype/
    '';
  });
in {
  home.packages = with pkgs; [
    dot-gothic16
    nerd-fonts.fira-code
    font-awesome
    roboto
    roboto-mono
    iosevka-bin
    (iosevka-bin.override { variant = "Aile"; })
    et-book
    terminus_font
    siji
    scientifica
  ];
  fonts.fontconfig.enable = true;
}

