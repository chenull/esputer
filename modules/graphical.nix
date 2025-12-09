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

    # Niri
    programs.niri.enable = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
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
      # Niri configuration.
      xdg.configFile."niri/config.kdl".source = ../files/niri.kdl;

      # Theming
      home.pointerCursor = {
        # Whether to enable GTK configuration generation for `home.pointerCursor`.
        gtk.enable = true;

        # Package providing the cursor theme.
        package = cursorPackage;

        # The cursor name within the package.
        name = cursorName;

        # The cursor size.
        size = cursorSize;
      };

      gtk = {
        cursorTheme = {
          # Package providing the cursor theme.
          package = cursorPackage;

          # The name of the cursor theme within the package.
          name = cursorName;

          # The size of the cursor.
          size = cursorSize;
        };

        iconTheme = {
          # Package providing the icon theme.
          package = iconPackage;

          # The name of the icon theme within the package.
          name = iconName;
        };
      };

      programs.fuzzel = {
        # Whether to enable the Fuzzel launcher.
        enable = true;

        # Width of the border in pixels.
        settings.border.width = 2;

        # Rounding of the corners in pixels.
        settings.border.radius = 0;

        settings.colors = rec {
          background = "0d0d0dcc";
          border = "0080ffcc";
          input = "e6ffffff";
          match = "ff0080ff";
          prompt = "00ffffcc";
          selection = "2073ff88";
          selection-text = text;
          selection-match = "00ffffff";
          text = "ffffffff";
        };

        settings.main = rec {
          # Appearance
          font = "monospace:size=12.5";
          icon-theme = iconName;

          # Padding in pixels.
          horizontal-pad = 6;
          inner-pad = horizontal-pad;
          vertical-pad = horizontal-pad;

          # Line height in pixels.
          line-height = 20;

          # Whether to use bold text for selected items. Works best with mono-spaced fonts.
          use-bold = "yes";
        };
      };
    };
}
