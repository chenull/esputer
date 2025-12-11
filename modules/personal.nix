let
  shared = {pkgs, ...}: {
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        alejandra
        ansible # TODO: Move to modules/ansible.nix
        ansible-lint
        docker-compose
        element-desktop # client for matrix.org
        fastfetch
        pritunl-client # VPN client
        runme # Execute commands inside your docs
        slack # JogjaCamp chats
        tgpt # terminal GPT
        treemd # cli markdown navigator
        winbox4 # Mikrotik RouterOS GUI
        yt-dlp # youtube downloader
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
        apparency # Toolkit for analysing macOS app
        chatgpt # AI chatbot
        iina # video player
        itsycal # Tiny menu bar calendar
        utm # system emulator and virtual machine host
        ;
    };
    homebrew = {
      enable = true;
      brews = [
        "colima"
      ];
      casks = [
        "affinity-photo"
        "bettertouchtool"
        "cursor"
        "discord"
        "google-chrome"
        "hammerspoon"
        # TODO: "karabiner-elements"
        "monodraw"
        "powerphotos"
        "setapp"
        "spotify"
        "surfshark"
        "telegram"
        "whatsapp"
        "zoom"
      ];
      masApps = {
        "flighty" = 1358823008;
        "telephone" = 406825478;
        "polarr-photo-editor" = 1077124956; # acccount is chenull@yahoo.com
      };
    };
  };

  nixosModule = {pkgs, ...}: {
    imports = [shared];

    # TODO: Add packages:
    # - NetworkManager-openvpn
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        kaidan # XMPP client
        telegram-desktop
        whatsapp-electron
        ;
    };
    # No password required for sudo
    security.sudo.wheelNeedsPassword = false;
  };

  homeModule = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.stdenv) hostPlatform;
    inherit (lib) optionalAttrs;
  in {
    home.packages = builtins.attrValues ({
        inherit (pkgs) gh gramps;
      }
      // optionalAttrs hostPlatform.isDarwin {
        inherit (pkgs) joplin-desktop;
      });

    programs.firefox.profiles.personal.isDefault = true;

    home.file."Documents/iCloud" = lib.mkIf hostPlatform.isDarwin {
      source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/Library/Mobile Documents/com~apple~CloudDocs/Documents";
    };
  };
}
