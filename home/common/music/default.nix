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
        audio_output {
            type "fifo"
            name "my_fifo"
            path "/tmp/mpd.fifo"
            format "44100:16:2"
        }
    '';
  };

  programs.rmpc.enable = true;

  programs.beets = {
    enable = true;
    settings = {
      directory = "~/media/music/";
      library = "~/media/musiclibrary.db";

      "import" = {
        move = true;
      };

      plugins = [
        "musicbrainz"
        "fromfilename"
        "fetchart"
        "chroma"
      ];
    };
  };

  programs.ncmpcpp = let
    song-change-sh = pkgs.writeShellScript "song-change.sh" ''
        SONG=$(mpc current)
        DIR=$(dirname "$(mpc --format "$XDG_MUSIC_DIR"/%file% | head -n 1)")
        COVER_ART="$(find "$DIR" -name "cover.*")"
        notify-send -i "$COVER_ART" "Now Playing:" "$SONG"
      '';
    in {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    settings = {
      # visualizer_data_source = "/tmp/mpd.fifo";
      # visualizer_output_name = "Visualizer";
      # visualizer_in_stereo = "yes";
      # visualizer_type = "spectrum";
      # visualizer_look = "+|";
      # visualizer_color = "red";
      # song_list_format = "{{%a - %t}|{%f}}{$R%l}";
      # song_status_format = "{{%a{ $2//$9 %b{, %y}} $2//$9 }{%t$/b}}|{$b%f$/b}";
      # song_library_format = "{{%a - %t} (%b)}|{%f}";
      # now_playing_prefix = "$b$5";
      # now_playing_suffix = "$/b$9";
      # playlist_display_mode = "classic";
      # autocenter_mode = true;
      # progressbar_look = "─╼ ";
      # header_visibility = false;
      # statusbar_visibility = true;
      # titles_visibility = false;
      # follow_now_playing_lyrics = false;
      enable_window_title = false;
      # colors_enabled = true;
      # empty_tag_color = "red";
      # header_window_color = "yellow";
      # volume_color = "yellow";
      # state_line_color = "red";
      # state_flags_color = "yellow";
      # main_window_color = "default";
      # color1 = "red";
      # color2 = "red";
      # progressbar_color = "black";
      # progressbar_elapsed_color = "red";
      # statusbar_color = "default";
      # alternative_ui_separator_color = "magenta";
      # window_border_color = "yellow";
      # active_window_border = "magenta";
      execute_on_song_change = "${song-change-sh}";
    };
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
