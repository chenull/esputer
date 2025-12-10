let
  shared = {pkgs, ...}: {
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        fastfetch
        treemd # cli markdown navigator
        ;
    };
  };
in {
  imports = [
    "graphical"
    "zsh"
    "ghostty"
    "alacritty"
  ];

  darwinModule = {pkgs, ...}: {
    imports = [shared];
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        apparency
        ;
    };

    # TODO: Migrate to home-manager mas module

    # My apps from the App Store
    # Flighty
    # launchd.user.agents.install-flighty = {
    #   command = "${lib.getExe pkgs.mas} install 1358823008";
    #   serviceConfig.RunAtLoad = true;
    # };

    # Telephone
    # launchd.user.agents.install-telephone = {
    #   command = "${lib.getExe pkgs.mas} install 406825478";
    #   serviceConfig.RunAtLoad = true;
    # };

    # Polarr Photo Editor, email acccount is chenull@yahoo.com
    # launchd.user.agents.install-polarr-photo-editor = {
    #   command = "${lib.getExe pkgs.mas} install 1077124956";
    #   serviceConfig.RunAtLoad = true;
    # };
  };
  nixosModule = {...}: {
    imports = [shared];

    # No password required for sudo
    security.sudo.wheelNeedsPassword = false;
  };
}
