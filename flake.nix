{
  description = "NixOS configuration based on dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      createNixosConfig = { profile, enableSsh ? true }: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (import ./profiles/${profile})
          home-manager.nixosModules.home-manager
          {
            config = {
              inherit enableSsh;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
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
