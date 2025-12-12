# Module: dock
#
# Configure macOS dock items by adding to existing items (not replacing).
{
  # Darwin configuration.
  darwinModule = {
    lib,
    config,
    pkgs,
    ...
  }: let
    # Path to the Python script file (relative to this module file)
    # From modules/macos.nix, go up one level to repo root, then into files/
    scriptPath = ../files/add-dock-items.py;
    # Create the script in the nix store
    # Using lib.readFile like other modules do
    dockScript = pkgs.writeScript "add-dock-items.py" (lib.readFile scriptPath);
  in {
    # Define the dock.apps option
    options.macosDock.apps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of application paths to add to the macOS dock (adds to existing items)";
    };

    # Add dock items using a named activation script
    config = lib.mkIf (config.macosDock.apps != []) {
      system.activationScripts.postActivation = {
        text = ''
          echo "=== addDockItems activation script ===" >&2
          # Only run if a user is logged in and dock plist exists
          CONSOLE_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
          if [ -z "$CONSOLE_USER" ] || [ "$CONSOLE_USER" = "loginwindow" ]; then
            echo "No user logged in, skipping dock items addition" >&2
            exit 0
          fi

          DOCK_PLIST="/Users/$CONSOLE_USER/Library/Preferences/com.apple.dock.plist"
          if [ ! -f "$DOCK_PLIST" ]; then
            echo "Dock plist not found, skipping dock items addition" >&2
            exit 0
          fi

          echo "Running dock items script for user: $CONSOLE_USER" >&2
          # Run the Python script to add dock items (it handles merging with existing items)
          ${dockScript} ${lib.concatStringsSep " " (map lib.escapeShellArg config.macosDock.apps)} || {
            EXIT_CODE=$?
            # Don't fail activation if script can't run
            if [ $EXIT_CODE -eq 1 ]; then
              echo "Dock items script may have failed (this is normal if dock is not ready)" >&2
            fi
            exit 0
          }
          echo "=== addDockItems activation script finished ===" >&2
        '';
      };
    };
  };

  # NixOS configuration (no-op for dock)
  nixosModule = {...}: {};

  # Home configuration (no-op for dock)
  homeModule = {...}: {};
}
