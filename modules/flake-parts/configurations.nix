{lib, ...}: {
  options = {
    # nixosConfigurations and darwinConfigurations are already provided by flake-parts
    # Only declare homeConfigurations if it's not already provided
    flake.homeConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
    };
  };
}
