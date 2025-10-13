{
  description = "NixOS configuration based on dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }:
    let
      system = "x86_64-linux";
      createNixosConfig = { profile, enableSsh ? true }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko enableSsh; };
        modules = [
          disko.nixosModules.disko
          (import ./profiles/${profile})
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { pkgs = nixpkgs.legacyPackages.${system}; };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        core = createNixosConfig { profile = "core"; };
        console = createNixosConfig { profile = "console"; };
        desktop = createNixosConfig { profile = "desktop"; };
      };
    };
}
