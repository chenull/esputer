{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = [];

      shellHook = ''
        echo "Hello, World from devShells.nix!"
      '';
    };
  };
}
