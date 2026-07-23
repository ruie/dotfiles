{
  description = "ruie dotfiles — one sync for every machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { nixpkgs, home-manager, nix-darwin, nix-homebrew, ... }:
    let
      # The one line to change if the macOS username differs.
      macUser = "ruie";
      mkHome = username:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home/common.nix ];
          extraSpecialArgs = { inherit username; };
        };
    in {
      # Linux machines: standalone home-manager, applied by sync.sh as $USER.
      homeConfigurations = {
        vdelapena = mkHome "vdelapena"; # work — Windows WSL
        ruie = mkHome "ruie"; # Hetzner vps
      };

      # Personal MacBook: nix-darwin owns the system + Homebrew,
      # home-manager runs as a module with the same home/common.nix.
      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        specialArgs = { user = macUser; };
        modules = [
          ./darwin/configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { username = macUser; };
            home-manager.users.${macUser} = import ./home/common.nix;
          }
        ];
      };
    };
}
