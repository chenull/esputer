{
  imports = ["graphical"];

  darwinModule = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages =
      builtins.attrValues {inherit (pkgs) apparency;};

    # My apps from the App Store
    # Flighty
    launchd.user.agents.install-flighty = {
      command = "${lib.getExe pkgs.mas} install 1358823008";
      serviceConfig.RunAtLoad = true;
    };

    # Telephone
    launchd.user.agents.install-telephone = {
      command = "${lib.getExe pkgs.mas} install 406825478";
      serviceConfig.RunAtLoad = true;
    };

    # Polarr Photo Editor, email acccount is chenull@yahoo.com
    launchd.user.agents.install-polarr-photo-editor = {
      command = "${lib.getExe pkgs.mas} install 1077124956";
      serviceConfig.RunAtLoad = true;
    };
  };
}
