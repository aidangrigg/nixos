{ config, lib, pkgs, ... }: {
  imports = [
    ./dmenu.nix
    ./st.nix
  ];
}
