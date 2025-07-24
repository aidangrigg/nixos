{ pkgs, ... }: {
  imports = [
    ./../common
  ];

  home.packages = with pkgs; [

  ];

  programs.foot.enable = true;

  wayland.windowManager.river = {
    enable = true;
  };
}
