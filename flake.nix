{
  description = "ruie dotfiles — one sync for every machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mkHome = username:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/common.nix ];
          extraSpecialArgs = { inherit username; };
        };
    in {
      homeConfigurations = {
        vdelapena = mkHome "vdelapena"; # WSL workstation
        ruie = mkHome "ruie"; # Hetzner vps
      };
    };
}
