{ pkgs, ... }: {

  home.packages = with pkgs; [
    mpc
    yt-dlp
  ];

  services.mpd = {
    enable = true;
    extraConfig = ''
      audio_output {
        type "pulse"
        name "PulseAudio"
      }
    '';
  };

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

      # { key = "ctrl-h"; command = "show_help"; }
      # { key = "ctrl-m"; command = "show_media_library"; }
      # { key = "ctrl-m"; command = "toggle_media_library_columns_mode"; }
      # { key = "ctrl-r"; command = "show_playlist_editor"; }
      # { key = "ctrl-t"; command = "show_tag_editor"; }
      # { key = "P"; command = "show_playlist"; }
      # { key = "ctrl-f"; command = "show_browser"; }
      # { key = "ctrl-f"; command = "change_browse_mode"; }
      # { key = "ctrl-s"; command = "show_search_engine"; }
      # { key = "ctrl-s"; command = "reset_search_engine"; }
      # { key = "ctrl-n"; command = "next"; }
      # { key = "ctrl-p"; command = "previous"; }
    ];
  };
}
