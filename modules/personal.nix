let
  shared = {pkgs, ...}: {
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        alejandra
        ansible # TODO: Move to modules/ansible.nix
        ansible-lint
        discord # cross-platform voice and text chat
        fastfetch
        runme # Execute commands inside your docs
        slack # JogjaCamp chats
        telegram-desktop
        tgpt # terminal GPT
        treemd # cli markdown navigator
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
        itsycal # Tiny menu bar calendar
        utm # system emulator and virtual machine host
        # whatsapp-for-mac # Broken
        ;
    };

    # TODO: Migrate to home-manager mas module
    # - whatsapp
    # - telegram

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

    # homebrew brews
    # TODO: Add homebrew casks:
    # - spotify # spotify is too slow to be downloaded from nix cache

    programs.firefox.profiles.personal.isDefault = true;

    home.file."Documents/iCloud" = lib.mkIf hostPlatform.isDarwin {
      source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/Library/Mobile Documents/com~apple~CloudDocs/Documents";
    };
  };
}
