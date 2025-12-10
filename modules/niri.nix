# Module: niri
# Niri is a minimalistic window manager for the Linux desktop.
{
  # NixOS configuration.
  nixosModule = {...}: {
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

      # Fuzzel launcher.
      programs.fuzzel = {
        enable = true;
        settings.main = rec {
          font = "monospace:pixelsize=20";
          icon-theme = "Flat-Remix-Blue-Dark";
          horizontal-pad = 6;
          inner-pad = horizontal-pad;
          vertical-pad = horizontal-pad;
          use-bold = "yes";
          lines = 10;
        };
        settings.border = {
          width = 2;
          radius = 0;
        };
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
      };
    };
}
