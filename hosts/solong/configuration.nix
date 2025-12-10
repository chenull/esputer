{...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # wifi device: wlp0s20f3
  programs.captive-browser.interface = "wlp0s20f3";

  system.stateVersion = "25.11";
}
