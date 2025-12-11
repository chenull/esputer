let
  homeManagerStateVersion = "25.11";

  shared = {
    lib,
    configRevision,
    inputs,
    hostname,
    pkgs,
    ...
  }: {
    # Add flake revision to `nixos-version --json`
    system.configurationRevision = configRevision.full;

    networking.hostName = hostname;
    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    time.timeZone = "Asia/Jakarta";

    nix.channel.enable = false;

    # Base system packages.
    environment.systemPackages = with pkgs;
      [
        # File / Disk Utilities
        duf # df / disk utilization
        dust # du / disk usage
        eza # ls
        fd # find files
        ncdu # disk usage analyzer
        ranger

        # Process
        btop
        git # TODO: move to modules/git.nix
        htop
        killall
        lsof
        pik # kill process(es) interactively
        procps # get process info using procfs

        # Shell Utilities
        bat # cat
        fzf
        just # run project-specific commands
        peco
        tmux # TODO: Move to modules/tmux.nix using programs.tmux

        # System Utilities
        nix-output-monitor
        ripgrep
        tree
        unzip
        vim
        wget
        zigfetch
        zip

        # Network Utilities
        inetutils # network tools: telnet, ifconfig, whois, etc.
        ipcalc
        ipinfo
        mtr
        sipcalc

        # Hardware Utilities
        pciutils
        smartmontools
        usbutils
      ]
      # Platform-specific packages (Linux only)
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        hwinfo
        procfd # lsof / list open file descriptors
        reptyr # attach a process to a new terminal
      ]
      ++ [
        inputs.home-manager.packages.${stdenv.hostPlatform.system}.default
      ];

    environment.shellAliases = {
      "_" = "sudo";
      "..." = "cd ../../..";
      "...." = "cd ../../../..";
      "....." = "cd ../../../../..";
      "......" = "cd ../../../../../..";
      du = "dust";
      df = "duf";
      free = "free -h";
      top = "btop";
      ls = "eza --icons";
      ll = "eza -l --icons";
      la = "eza -la --icons";

      # Git aliases
      gaa = "git add --all";
      gst = "git status";
      gcam = "git commit -a -m";
      gcmsg = "git commit -m";
      gcl = "git clone";
      ggpull = ''git pull origin "$(git symbolic-ref --short HEAD 2>/dev/null)'';
      ggpush = ''git push origin "$(git symbolic-ref --short HEAD 2>/dev/null)'';
    };

    # root's home configuration
    home-manager.users.root = {
      home.stateVersion = homeManagerStateVersion;
      home.file.".config/zigfetch/config.json".source = ../files/zigfetch.json;
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
    programs.mtr.enable = true;

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
    users.users.root = {
      uid = 0;
      # Necessary otherwise `home-manager` will error out
      home = "/var/root";
      # WORKAROUND: Fixes alacritty's terminfo not being found over SSH
      shell = pkgs.zsh;
    };
  };

  homeModule = {
    home.stateVersion = homeManagerStateVersion;

    home.sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      MANROFFOPT = "-P -c";
    };
    programs.home-manager.enable = true;

    xdg.configFile."zigfetch/config.json".source = ../files/zigfetch.json;

    # Disable manual generation to avoid builtins.toFile warning
    # See: https://github.com/nix-community/home-manager/issues/7935
    manual.manpages.enable = false;
  };
}
