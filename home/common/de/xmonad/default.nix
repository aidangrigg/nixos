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
       , bgColor  =     "#222222"
       , fgColor  =     "#555555" 
       , position = TopH 25
       , commands =
         [ Run MultiCpu      [ "--template", "<fc=white>[C] <total>%</fc>" ] 30
         , Run Memory        [ "--template", "<fc=white>[R] <used>M</fc>" ] 30
         , Run MultiCoreTemp [ "--template", "<fc=white><max>°C</fc>" ] 30
	       , Run DiskU         [("/", "<fc=white>[D] <free></fc>")] [] 2400
         , Run Date          "<fc=white>%H:%M %a %b %d, %Y</fc>" "date" 10
         , Run XMonadLog
         ]
        , sepChar  = "%"
        , alignSep = "}{"
        , template = " %XMonadLog% }{ %multicpu% %multicoretemp% // %memory% // %disku% // %date% "
        }
    '';
  };
}
