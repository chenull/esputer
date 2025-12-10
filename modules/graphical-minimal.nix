{
  imports = ["fonts"];

  darwinModule = {
    user,
    pkgs,
    ...
  }: {
    environment.systemPackages =
      builtins.attrValues {inherit (pkgs) rectangle;};

    launchd.user.agents.rectangle = {
      command = ''"/Applications/Nix Apps/Rectangle.app/Contents/MacOS/Rectangle"'';
      serviceConfig.RunAtLoad = true;
    };

    # Close Terminal if shell exited cleanly
    system.activationScripts.extraActivation.text = ''
      if [[ -f ~${user}/Library/Preferences/com.apple.Terminal.plist ]]; then
        sudo -u ${user} plutil -replace "Window Settings.Basic.shellExitAction" -integer 1 ~${user}/Library/Preferences/com.apple.Terminal.plist
      fi
    '';

    # Screenshots location
    system.defaults.screencapture.location = "~/Pictures/Screenshots";

    # Disable automatic capitalization
    system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;

    # disable `Add full stop with double-space`
    system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;

    # Disable dock autohide
    system.defaults.dock.autohide = false;
  };

  nixosModule = {pkgs, ...}: {
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        bemoji
        gparted
        myxer
        ungoogled-chromium
        ;
      kde-falkon = pkgs.kdePackages.falkon;
      thunar = pkgs.xfce.thunar;
    };

    # X server
    services.xserver = {
      enable = true;
      # lightdm display manager
      displayManager.lightdm.enable = true;
      # IceWM window manager
      windowManager = {
        icewm.enable = true;
      };
    };

    services.pulseaudio.enable = false;
    services.pipewire.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.alsa.support32Bit = true;
    services.pipewire.pulse.enable = true;

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
