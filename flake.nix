{
  description = "Cowboy Linux config for the Lattepanda 3 Delta";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
  };

  outputs = { nixpkgs, ... } @ inputs: {
    nixosConfigurations.cowboy-linux = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
