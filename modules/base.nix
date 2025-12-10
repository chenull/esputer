let
  shared = {
    lib,
    configRevision,
    inputs,
    hostname,
    pkgs,
    user,
    ...
  }: {
    # Add flake revision to `nixos-version --json`
    system.configurationRevision = configRevision.full;

    networking.hostName = hostname;

    time.timeZone = "Asia/Jakarta";

    nix.channel.enable = false;

    # Base system packages.
    environment.systemPackages = with pkgs;
      [
        # File / Disk Utilities
        duf # df / disk utilization
        dust # du / disk usage
        ncdu # disk usage analyzer
        eza # ls
        ranger

        # Process
        btop
        killall
        pik # kill process(es) interactively
        inetutils # network tools: telnet, ifconfig, whois, etc.
        lsof
        procps # get process info using procfs
        git # TODO: move to modules/git.nix

        # Shell Utilities
        bat # cat
        peco
        nix-output-monitor
        ripgrep
        tmux
        tree
        unzip
        usbutils
        wget
        vim
        zip

        # Platform-specific packages (Linux only)
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        reptyr # attach a process to a new terminal
        procfd # lsof / list open file descriptors
      ]
      ++ [
        inputs.home-manager.packages.${stdenv.hostPlatform.system}.default
      ];

    environment.shellAliases = {
      du = "dust";
      df = "duf";
      free = "free -h";
      top = "btop";
      ls = "eza --icons";
      ll = "eza -l --icons";
      la = "eza -la --icons";
    };

    # Install all terminfo outputs
    # alacritty, contour, foot, ghostty, kitty, mtm, rio, rxvt st, termite, tmux, wezterm, yaft
    environment.enableAllTerminfo = true;

    users.users.${user} = {
      # WORKAROUND: Fixes alacritty's terminfo not being found on macOS over SSH
      shell = pkgs.zsh;
    };
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
    home.stateVersion = "25.11";

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
