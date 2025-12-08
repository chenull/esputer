{...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO: move to modules/nix.nix
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # TODO: move to modules/openssh.nix
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
