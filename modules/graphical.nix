# Module: graphical
# Graphical apps for
let
  # Shared configuration.
  # Can be used to set configuration that is shared across
  # `darwin`, `nixos` and `home` modules below.
  shared = {...}: {
  };
in {
  # Import other modules if needed. e.g:
  # imports = [ "graphical" "terminal" ];
  imports = ["graphical-minimal"];

  # Darwin configuration.
  darwinModule = {...}: {
    # Import shared configuration defined in `let ... in` block above.
    imports = [shared];
  };
  # NixOS configuration.
  nixosModule = {...}: {
    imports = [shared];
  };

  # Home configuration.
  homeModule = {...}: {};
}
