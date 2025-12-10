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

      # Waybar bar.
      programs.waybar = {
        # Whether to enable the Waybar bar.
        enable = true;

        # Whether to enable Waybar systemd integration.
        # This allows Waybar to automatically start with the desktop.
        systemd.enable = false;
      };

      # Link Waybar's configuration files.
      xdg.configFile."waybar/config".source = ../files/waybar/config.json;
      xdg.configFile."waybar/style.css".source = ../files/waybar/style.css;

      # Icons
      xdg.configFile."waybar/icons/cpu.svg".source = ../files/icons/cpu.svg;
      xdg.configFile."waybar/icons/close.svg".source = ../files/icons/close.svg;

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

      # Fuzzel launcher.
      programs.fuzzel = {
        enable = true;
        settings.border.width = 2;
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
          font = "monospace:size=12.5";
          icon-theme = iconName;
          horizontal-pad = 6;
          inner-pad = horizontal-pad;
          vertical-pad = horizontal-pad;
          line-height = 20;
          use-bold = "yes";
        };
      };
    };
}
