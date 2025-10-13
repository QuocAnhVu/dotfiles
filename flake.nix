{
  description = "NixOS configuration based on dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github.com:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR"; # Add NUR input
  };

  outputs = { self, nixpkgs, home-manager, disko, nur, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        "vm-core" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit disko; enableSsh = true; };
          modules = [
            disko.nixosModules.disko
            ./hosts/vm
            ./profiles/core
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { pkgs = nixpkgs.legacyPackages.${system}; };
            }
          ];
        };
        "desktop-full" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit disko nur; enableSsh = false; }; # Pass nur as specialArgs
          modules = [
            disko.nixosModules.disko
            ./hosts/desktop
            ./profiles/desktop
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { pkgs = nixpkgs.legacyPackages.${system}; };
            }
          ];
        };
      };
    };
}
