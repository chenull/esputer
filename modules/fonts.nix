# Module: fonts
let
  shared = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      nerd-fonts.sauce-code-pro
    ];
  };
in {
  # Darwin system fonts.
  darwinModule = {...}: {
    # Import shared configuration defined in `let ... in` block above.
    imports = [shared];
  };

  # NixOS system fonts.
  nixosModule = {pkgs, ...}: {
    imports = [shared];
    fonts = {
      # Whether to enable a basic set of fonts to provide a reasonable coverage of Unicode.
      # Especially useful for emojis (Noto Color Emoji) & legacy characters support.
      enableDefaultPackages = true;

      # Whether to link system fonts to `/run/current-system/sw/share/X11/fonts` for easier access.
      # Some programs & Flatpaks require this.
      fontDir.enable = true;

      fontconfig = {
        # Whether to generate system fonts cache for 32-bit applications.
        cache32Bit = true;

        # Default fonts to use, per category.
        # Multiple fonts may be listed in case one does not support certain characters, such as emojis.
        defaultFonts = {
          emoji = ["Noto Color Emoji"];
          monospace = ["UbuntuMono Nerd Font" "Noto Color Emoji"];
          sansSerif = ["Ubuntu Nerd Font" "Noto Color Emoji"];
          serif = ["Ubuntu Nerd Font" "Noto Color Emoji"];
        };

        # Whether to use embedded bitmaps in fonts like Calibri or Noto emojis.
        useEmbeddedBitmaps = true;
      };

      # System wide fonts.
      packages = with pkgs; [
        # Source Code Pro Nerd Font.
        nerd-fonts.sauce-code-pro

        # Ubuntu Nerd Fonts.
        nerd-fonts.ubuntu
        nerd-fonts.ubuntu-mono

        # Additional symbols & interlingual support.
        noto-fonts-cjk-sans
        noto-fonts
      ];
    };
  };

  # User font configuration.
  homeModule = {...}: {
    gtk.font = {
      # Font to use in graphical programs for the user.
      name = "sans";
      # Font size to use in graphical programs for the user.
      size = 11;
    };
  };
}
