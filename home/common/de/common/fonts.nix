{ pkgs, lib, ... }:
# let
#   my-tewi-font = pkgs.tewi-font.overrideAttrs (old: {
#     src = pkgs.fetchFromGitHub {
#       owner = "Tecate";
#       repo = "bitmap-fonts";
#       rev = "5c101c91bf2ed0039aad02f9bf76ddb2018b1f21";
#       sha256 = "1axv9bv10xlcmgfyjh3z5kn5fkg3m6n1kskcs5hvlmyb6m1zk91j";
#     };
#   });
# in
{
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    font-awesome
    roboto
    roboto-mono
    iosevka-bin
    (iosevka-bin.override { variant = "Aile"; })
    etBook
    terminus_font
    # siji
    scientifica
    tewi-font
  ];
  fonts.fontconfig.enable = true;
}

