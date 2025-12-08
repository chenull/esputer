{...}: {
  # Detsys nix required upstream nix to be disabled
  nix.enable = false;

  # Nix-darwin state version
  system.stateVersion = 6;
}
