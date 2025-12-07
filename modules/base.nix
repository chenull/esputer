let
  shared = {
    configRevision,
    inputs,
    hostname,
    pkgs,
    ...
  }: {
    # Add flake revision to `nixos-version --json`
    system.configurationRevision = configRevision.full;

    networking.hostName = hostname;

    time.timeZone = "Asia/Jakarta";

    nix.channel.enable = false;

    environment.systemPackages =
      (builtins.attrValues {
        inherit
          (pkgs)
          killall
          nix-output-monitor
          unzip
          wget
          vim
          zip
          ;
      })
      ++ [
        inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
in {
  imports = [];

  nixosModule = {user, ...}: {
    imports = [shared];

    networking.networkmanager.enable = true;

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel"];
    };
  };

  darwinModule = {...}: {
    imports = [shared];
  };

  homeModule = {
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.stdenv) hostPlatform;
  in {
    home.stateVersion = "25.11";

    home.packages = builtins.attrValues {
      inherit
        (pkgs)
        ripgrep
        ;
      reptyr = lib.mkIf hostPlatform.isLinux pkgs.reptyr;
    };

    home.sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      MANROFFOPT = "-P -c";
    };

    programs.home-manager.enable = true;
    # Disable manual generation to avoid builtins.toFile warning
    # See: https://github.com/nix-community/home-manager/issues/7935
    manual.manpages.enable = false;
  };
}
