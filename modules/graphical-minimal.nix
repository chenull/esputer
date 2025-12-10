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
  };
}
