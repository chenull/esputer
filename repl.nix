# Helper file to access specialArgs in nix repl
# Usage: nix repl --file repl.nix
# Or inside nix repl: :l repl.nix
let
  flake = builtins.getFlake (toString ./.);
  # Re-evaluate specialArgs the same way they're defined in flake.nix
  specialArgs = {
    self-lib = (import ./lib.nix) {inherit (flake.inputs.nixpkgs) lib;};
  };
in {
  inherit flake;
  inherit specialArgs;
  # Direct access to your specialArgs
  self-lib = specialArgs.self-lib;
}
