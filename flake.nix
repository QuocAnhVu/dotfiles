{
  description = "Dotfiles: home-manager profiles for desktops, dev environments and servers";

  inputs = {
    # nixpkgs-unstable (not nixos-unstable): these profiles run on Debian/Fedora, not NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Flatpak apps (services.flatpak in home/workstation.nix)
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = { nixpkgs, home-manager, nix-flatpak, ... }:
    let
      system = "x86_64-linux";
      # Login names: each gets every role below, as <user>@<role>
      users = [ "quocanh" "user" ];
      roles = {
        workstation = { profile = "workstation"; };
        desktop = { profile = "desktop"; };
        dev = { profile = "full"; };
        # Store copies instead of links, so servers don't need a dotfiles checkout
        server = { profile = "minimal"; liveLinks = false; };
      };
      mkHome = user: { profile, liveLinks ? true }: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          nix-flatpak.homeManagerModules.nix-flatpak
          ./home/${profile}.nix
          {
            home.username = user;
            home.homeDirectory = "/home/${user}";
            dotfiles.liveLinks = liveLinks;
          }
        ];
      };
    in
    {
      homeConfigurations = builtins.listToAttrs (nixpkgs.lib.concatMap
        (user: nixpkgs.lib.mapAttrsToList
          (role: args: { name = "${user}@${role}"; value = mkHome user args; })
          roles)
        users);

      # Pinned home-manager CLI for the first switch (see home.sh)
      packages.${system}.home-manager = home-manager.packages.${system}.home-manager;
    };
}
