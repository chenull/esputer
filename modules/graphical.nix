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
        ;
    };

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
      xdg.configFile."waybar/icons/cpu.svg".source = ../files/waybar/icons/cpu.svg;
      xdg.configFile."waybar/icons/close.svg".source = ../files/waybar/icons/close.svg;

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
