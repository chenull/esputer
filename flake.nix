{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  # inputs follows
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        self-lib = (import ./lib.nix) {inherit (inputs.nixpkgs) lib;};
      };
    } {
      imports = [
        inputs.home-manager.flakeModules.home-manager
        ./hosts/hosts.nix
      ];
      systems = ["x86_64-linux" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            echo "Hello, ffrWorld from devShells.nix!"
          '';
        };
      };
    };
}
