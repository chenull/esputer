{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        self-lib = (import ./lib.nix) {inherit (inputs.nixpkgs) lib;};
      };
    } {
      imports = [
        ./hosts/flake-module.nix
        ./modules/flake-parts/flake-module.nix
      ];
      systems = ["x86_64-linux" "aarch64-darwin"];
    };
}
