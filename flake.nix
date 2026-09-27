{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {self, nixpkgs, nixpkgs-unstable, home-manager, ...} @ inputs:
    let
      inherit (self) outputs;
      pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
    in {
      overlays = import ./overlays {inherit inputs;};

      nixosConfigurations = {
        malzeno = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          modules = [
            ./hosts/malzeno/configuration.nix
            # home-manager.nixosModules.home-manager
            # {
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;
            #   home-manager.extraSpecialArgs = {inherit inputs outputs pkgs-unstable;};
            #   home-manager.users = {
            #     aidan = import ./home/aidan.nix;
            #     work  = import ./home/work.nix;
            #   };
            # }
          ];
        };

        rathian = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          modules = [
            ./hosts/rathian/configuration.nix
          ];
        };
      };

      homeConfigurations = let
        dotfilesDirectory = "/home/aidan/nix/dotfiles";
      in {
        malzeno = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {inherit inputs outputs dotfilesDirectory pkgs-unstable;};
          modules = [./home/malzeno.nix];
        };

        rathian = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {inherit inputs outputs dotfilesDirectory pkgs-unstable;};
          modules = [./home/rathian.nix];
        };

        work = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {inherit inputs outputs dotfilesDirectory pkgs-unstable;};
          modules = [./home/work.nix];
        };
      };
    };
}
