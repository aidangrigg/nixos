{ pkgs, ... }: {

  home.packages = with pkgs; [
    mpc
    yt-dlp
    picard
    ueberzugpp
  ];

  services.mpd = {
    enable = true;
    # network.listenAddress = "any";
    extraConfig = ''
        audio_output {
          type "pipewire"
          name "Pipewire Output"
        }
    '';
  };

  programs.rmpc.enable = true;

  programs.ncmpcpp = {
    enable = true;
    bindings = [
      { key = "j"; command = "scroll_down"; }
      { key = "k"; command = "scroll_up"; }
      { key = "h"; command = "previous_column"; }
      { key = "l"; command = "next_column"; }
      { key = "n"; command = "next_found_item"; }
      { key = "N"; command = "previous_found_item"; }
      { key = "ctrl-u"; command = "page_up"; }
      { key = "ctrl-d"; command = "page_down"; }
    ];
  };
}
