{
  # TODO: Add wireless module
  # imports = [ "wireless" ];

  nixosModule = {
    lib,
    pkgs,
    user,
    ...
  }: {
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        acpi # battery status
        light # backlight control
        zzz # sleep / hibernate laptop
        ;
    };

    # Automatically set the time zone based on the location.
    time.timeZone = lib.mkForce null;
    services.automatic-timezoned.enable = true;
    services.geoclue2.enableDemoAgent = lib.mkForce true;

    services.libinput.enable = true;

    services.logind.settings.Login = {
      HandlePowerKey = "lock";
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "lock";
    };

    systemd.sleep.extraConfig = ''
      HibernateDelaySec=5m
    '';

    users.users.${user}.extraGroups = ["video"];

    # Light backlight control
    programs.light.enable = true;

    # Dedicated Chrome instance to log into wifi captive portals.
    programs.captive-browser.enable = true;
  };

  darwinModule = {lib, ...}: {
    time.timeZone = lib.mkForce null;

    # environment.systemPackages =
    #   builtins.attrValues { inherit (pkgs) aldente ice-bar; };

    system.defaults.trackpad.Clicking = false;

    security.pam.services.sudo_local.touchIdAuth = true;
  };

  homeModule = {...}: {};
}
