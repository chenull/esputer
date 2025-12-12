{
  user,
  config,
  ...
}: {
  # Detsys nix required upstream nix to be disabled
  nix.enable = false;

  # Add dock apps installed by this configuration
  macosDock.apps = let
    homeDir = "/Users/${user}";
    appsDir = config.home-manager.users.${user}.targets.darwin.copyApps.directory;
  in [
    # from nixpkgs
    "/Applications/Nix Apps/Ghostty.app"
    "/Applications/Nix Apps/UTM.app"
    "/Applications/Nix Apps/Slack.app"
    # disable Element, weirdly appear as "Electron" in the dock if being opened during activation
    # "/Applications/Nix Apps/Element.app"
    # from home-manager
    "${homeDir}/${appsDir}/Ghostty.app"
    # from brew casks
    "/Applications/Google Chrome.app"
    "/Applications/Discord.app"
    "/Applications/Spotify.app"
    "/Applications/WhatsApp.app"
    "/Applications/Telegram.app"
  ];

  # Nix-darwin state version
  system.stateVersion = 6;
}
