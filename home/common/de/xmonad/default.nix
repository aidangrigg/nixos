{
  imports = [./../common];

  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./xmonad.hs;
    extraPackages = hpkgs: [
      hpkgs.xmobar
      hpkgs.org-mode
    ];
  };
  
  programs.xmobar = {
    enable = true;
    extraConfig = ''
Config { overrideRedirect = False
       , font     = "Roboto Mono 10"
       , bgColor  =     "#191816"
       , fgColor  =     "#FFFFFF" 
       , position = TopH 25
       , commands = [
         -- cpu activity monitor
         Run MultiCpu [ "--template" , "<fc=#5b7b85> </fc><fc=#e2d7cc><total>%</fc>" ] 30
	
        -- memory usage monitor
        , Run Memory         [ "--template" ,"<fc=#5b7b85> </fc><fc=#e2d7cc><used>M</fc>" ] 30

	      , Run DiskU [("/", "<fc=#5b7b85> </fc><fc=#e2d7cc><free></fc>")] [] 2400

        -- time and date indicator 
        --   (%F = y-m-d date, %a = day of week, %T = h:m:s time)
        , Run Date           "<box type=Bottom color=#5b7b85 width=2><fc=#e2d7cc> %H:%M %a %b %d, %Y</fc></box>" "date" 10
                    , Run XMonadLog
                    ]
       , sepChar  = "%"
       , alignSep = "}{"
       , template = "%XMonadLog% } [ %date% ] { [ %multicpu% ] [ %memory% ] [ %disku% ]  "
       }
    '';
  };
}
