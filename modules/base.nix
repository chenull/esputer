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

    # Base system packages.
    environment.systemPackages =
      (builtins.attrValues {
        inherit
          (pkgs)
          killall
          peco
          ranger
          git # TODO: move to modules/git.nix
          nix-output-monitor
          unzip
          usbutils
          wget
          vim
          zip
          ;
      })
      ++ [
        inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

    # Install all terminfo outputs
    # alacritty, contour, foot, ghostty, kitty, mtm, rio, rxvt st, termite, tmux, wezterm, yaft
    environment.enableAllTerminfo = true;
  };
in {
  imports = [
    "flakes"
    "terminal"
  ];

  nixosModule = {user, ...}: {
    imports = [shared];

    networking.networkmanager.enable = true;

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel"];
    };

    # Default language of the system.
    i18n.defaultLocale = "en_US.UTF-8";

    # Additional locale settings other than the language.
    i18n.extraLocaleSettings = rec {
      LC_ADDRESS = "id_ID.UTF-8";
      LC_IDENTIFICATION = LC_ADDRESS;
      LC_MEASUREMENT = LC_ADDRESS;
      LC_MONETARY = LC_ADDRESS;
      LC_NAME = LC_ADDRESS;
      LC_NUMERIC = LC_ADDRESS;
      LC_PAPER = LC_ADDRESS;
      LC_TELEPHONE = LC_ADDRESS;
      LC_TIME = "id_ID.UTF-8";
    };

    # Whether to keep the hardware clock in local time instead of UTC.
    # Mostly useful if dual-booting with a Windows-based operating system.
    time.hardwareClockInLocalTime = true;
  };

  darwinModule = {
    pkgs,
    user,
    ...
  }: {
    imports = [shared];
    system.primaryUser = user;
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        mas
        ;
    };
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
