# Module: graphical
#
# Graphical apps and configuration.
let
  shared = {...}: {
  };
in {
  # Import other modules if needed. e.g:
  imports = ["graphical-minimal"];

  # Darwin configuration.
  darwinModule = {...}: {
    imports = [shared];
  };
  # NixOS configuration.
  nixosModule = {pkgs, ...}: {
    imports = [shared];
    environment.systemPackages =
      builtins.attrValues {inherit (pkgs) gparted;};
  };

  # Home configuration.
  homeModule = {...}: {};
}
