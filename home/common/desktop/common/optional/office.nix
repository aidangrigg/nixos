{ pkgs, ... }:
{
   home.packages = with pkgs; [
     hunspell
     hunspellDicts.en_AU
     libreoffice
   ];
}
