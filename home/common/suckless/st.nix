{ pkgs, lib, config, ... }: {
  options = {
    programs.patched-st = {
      enable = lib.mkEnableOption "Patched st";
    };
  };

  config = lib.mkIf config.programs.patched-st.enable {
    home.packages = let
      st = pkgs.st.override({
        patches = [
          ./patches/st-scrollback-ringbuffer-0.9.2.diff
          ./patches/st-scrollback-mouse-0.9.2.diff
        ];
        conf = builtins.readFile ./config/st.config.h;
      });
    in [
      st
    ];
  };
}
