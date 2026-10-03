{
  description = "Dotfiles: home-manager profiles for desktops, dev environments and servers";

  inputs = {
    # nixpkgs-unstable (not nixos-unstable): these profiles run on Debian/Fedora, not NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      mkHome = { profile, liveLinks ? true }: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home/${profile}.nix
          { dotfiles.liveLinks = liveLinks; }
        ];
      };
    in
    {
      homeConfigurations = {
        "quocanh@desktop" = mkHome { profile = "desktop"; };
        "quocanh@dev" = mkHome { profile = "full"; };
        # Store copies instead of links, so servers don't need a dotfiles checkout
        "quocanh@server" = mkHome { profile = "minimal"; liveLinks = false; };
      };

      # Pinned home-manager CLI for the first switch (see home.sh)
      packages.${system}.home-manager = home-manager.packages.${system}.home-manager;
    };
}
