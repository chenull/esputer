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
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        ungoogled-chromium
        gnome-calendar
        karlender
        ;
    };
  };

  # Home configuration.
  homeModule = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv) hostPlatform;

    cursorPackage = pkgs.bibata-cursors;
    cursorName = "Bibata-Modern-Ice";
    cursorSize = 24;
    iconPackage = pkgs.flat-remix-icon-theme;
    iconName = "Flat-Remix-Blue-Dark";
  in
    mkIf (hostPlatform.isLinux) {
      # Theming
      home.pointerCursor = {
        # Whether to enable GTK configuration generation for `home.pointerCursor`.
        gtk.enable = true;

        package = cursorPackage;
        name = cursorName;
        size = cursorSize;
      };

      gtk = {
        cursorTheme = {
          package = cursorPackage;
          name = cursorName;
          size = cursorSize;
        };
        iconTheme = {
          package = iconPackage;
          name = iconName;
        };
      };
    };
}
