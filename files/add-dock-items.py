#!/usr/bin/env python3
"""
Add dock items for apps managed by nix
Usage: add-dock-items.py [--debug] <app1> <app2> ...

Options:
    --debug    Enable debug output
"""

import plistlib
import subprocess
import sys
import os
import urllib.parse
from pathlib import Path

# Global debug flag
DEBUG = False


def debug_print(*args, **kwargs):
    """Print debug message if debug is enabled."""
    if DEBUG:
        print("Debug:", *args, **kwargs)


def error_print(*args, **kwargs):
    """Print error message."""
    print("Error:", *args, file=sys.stderr, **kwargs)


def get_console_user():
    """Get the current console user (logged-in user)."""
    try:
        result = subprocess.run(
            ["scutil"],
            input="show State:/Users/ConsoleUser\n",
            text=True,
            capture_output=True,
            check=True,
        )
        for line in result.stdout.split("\n"):
            if "Name :" in line:
                user = line.split("Name :")[1].strip()
                if user and user != "loginwindow":
                    return user
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    return None


def get_user_home(username):
    """Get user home directory using dscl."""
    try:
        result = subprocess.run(
            ["dscl", ".", "-read", f"/Users/{username}", "NFSHomeDirectory"],
            capture_output=True,
            text=True,
            check=True,
        )
        for line in result.stdout.split("\n"):
            if "NFSHomeDirectory:" in line:
                home = line.split("NFSHomeDirectory:")[1].strip()
                if home and Path(home).is_dir():
                    return home
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    return None


def resolve_app_path(app_path):
    """Resolve symlinks to get the real path."""
    path = Path(app_path)
    if path.is_symlink():
        try:
            real_path = path.resolve()
            if real_path.exists():
                return str(real_path)
        except (OSError, RuntimeError):
            pass
    return str(path)


def get_app_url(app_path):
    """Get app URL from path. macOS dock uses URL-encoded paths with trailing slash for .app bundles."""
    # URL-encode the path
    encoded_path = urllib.parse.quote(str(app_path), safe="/")
    # Add trailing slash for .app bundles
    if app_path.endswith(".app"):
        return f"file://{encoded_path}/"
    return f"file://{encoded_path}"


def check_app_in_dock_status(dock_plist, app_url):
    """Check if app URL is in dock and return (is_in_dock, is_ghost) tuple."""
    if not dock_plist.exists():
        return (False, False)

    debug_print(f"Checking if app_url is in dock: {app_url}")

    try:
        with open(dock_plist, "rb") as f:
            dock_data = plistlib.load(f)

        if "persistent-apps" not in dock_data:
            debug_print("No persistent-apps key in dock plist")
            return (False, False)

        # Normalize the app_url we're looking for
        app_url_normalized = app_url.rstrip("/").lower()

        for app in dock_data["persistent-apps"]:
            if "tile-data" in app and "file-data" in app["tile-data"]:
                url = app["tile-data"]["file-data"].get("_CFURLString", "")
                if url:
                    # Normalize comparison
                    url_normalized = url.rstrip("/").lower()

                    if url_normalized == app_url_normalized:
                        # Check if the app path actually exists
                        app_path_from_url = url.replace("file://", "").rstrip("/")
                        app_path_decoded = urllib.parse.unquote(app_path_from_url)
                        app_exists = Path(app_path_decoded).exists()

                        if app_exists:
                            debug_print(
                                f"✓ Found matching URL in dock (app exists): {url}"
                            )
                            return (True, False)
                        else:
                            debug_print(
                                f"✗ Found matching URL in dock but app doesn't exist (ghost entry): {url}"
                            )
                            return (True, True)

    except (OSError, plistlib.InvalidFileException) as e:
        error_print(f"Failed to read dock plist: {e}")

    debug_print("No matching URL found in dock")
    return (False, False)


def app_url_in_dock(dock_plist, app_url):
    """Check if app URL is already in dock."""
    is_in_dock, _ = check_app_in_dock_status(dock_plist, app_url)
    return is_in_dock


def remove_app_from_dock(dock_plist, app_url):
    """Remove a specific app URL from dock plist."""
    if not dock_plist.exists():
        return False

    try:
        with open(dock_plist, "rb") as f:
            dock_data = plistlib.load(f)

        if "persistent-apps" not in dock_data:
            return False

        app_url_normalized = app_url.rstrip("/").lower()
        filtered_apps = []
        removed = False

        for app in dock_data["persistent-apps"]:
            if "tile-data" in app and "file-data" in app["tile-data"]:
                url = app["tile-data"]["file-data"].get("_CFURLString", "")
                if url:
                    url_normalized = url.rstrip("/").lower()
                    if url_normalized == app_url_normalized:
                        debug_print(f"Removing existing entry: {url}")
                        removed = True
                        continue
            filtered_apps.append(app)

        if removed:
            dock_data["persistent-apps"] = filtered_apps
            with open(dock_plist, "wb") as f:
                plistlib.dump(dock_data, f)
            debug_print("Removed app from dock plist")
            return True

        return False
    except (OSError, plistlib.InvalidFileException) as e:
        error_print(f"Failed to remove app from dock: {e}")
        return False


def clean_ghost_entries(dock_plist):
    """Remove ghost entries (apps that no longer exist) from dock plist."""
    if not dock_plist.exists():
        return False

    try:
        with open(dock_plist, "rb") as f:
            dock_data = plistlib.load(f)

        if "persistent-apps" not in dock_data:
            return False

        cleaned_apps = []
        removed_count = 0

        for app in dock_data["persistent-apps"]:
            if "tile-data" in app and "file-data" in app["tile-data"]:
                url = app["tile-data"]["file-data"].get("_CFURLString", "")
                if url:
                    app_path_from_url = url.replace("file://", "").rstrip("/")
                    app_path_decoded = urllib.parse.unquote(app_path_from_url)
                    if Path(app_path_decoded).exists():
                        cleaned_apps.append(app)
                    else:
                        removed_count += 1
                        debug_print(f"Removing ghost entry: {url}")
                else:
                    cleaned_apps.append(app)
            else:
                cleaned_apps.append(app)

        if removed_count > 0:
            dock_data["persistent-apps"] = cleaned_apps
            with open(dock_plist, "wb") as f:
                plistlib.dump(dock_data, f)
            debug_print(f"Cleaned {removed_count} ghost entries from dock")
            return True

        return False
    except (OSError, plistlib.InvalidFileException) as e:
        error_print(f"Failed to clean ghost entries: {e}")
        return False


def add_apps_to_dock(dock_plist, apps_to_add):
    """Add apps to dock plist. Returns (success, changes_made) tuple."""
    if not dock_plist.exists():
        return (False, False)

    if not apps_to_add:
        return (True, False)

    # Clean ghost entries first to ensure a clean state
    ghost_cleaned = clean_ghost_entries(dock_plist)

    # Read existing plist (fresh read after cleanup)
    try:
        with open(dock_plist, "rb") as f:
            dock_data = plistlib.load(f)
    except (OSError, plistlib.InvalidFileException) as e:
        error_print(f"Failed to read dock plist: {e}")
        return (False, False)

    if "persistent-apps" not in dock_data:
        dock_data["persistent-apps"] = []

    # Add each app
    added_count = 0
    for app_url in apps_to_add:
        debug_print(f"Adding app_url to dock: {app_url}")

        # Extract app path from URL
        app_path = app_url.replace("file://", "").rstrip("/")
        # URL-decode
        app_path = urllib.parse.unquote(app_path)

        # Get app name
        app_name = Path(app_path).stem

        # Create the dock entry
        new_entry = {
            "tile-data": {
                "file-data": {"_CFURLString": app_url, "_CFURLStringType": 15},
                "file-label": app_name,
                "file-type": 1,
                "file-mod-date": 0,
            },
            "tile-type": "file-tile",
        }

        dock_data["persistent-apps"].append(new_entry)
        added_count += 1
        debug_print(f"Successfully added {app_name} to dock plist")

    # Write back
    try:
        with open(dock_plist, "wb") as f:
            plistlib.dump(dock_data, f)
        debug_print("Dock plist updated successfully")
        changes_made = added_count > 0 or ghost_cleaned
        return (True, changes_made)
    except OSError as e:
        error_print(f"Failed to write dock plist: {e}")
        return (False, False)


def restart_dock(console_user, user_uid):
    """Restart dock to apply changes."""
    current_user = os.getenv("USER") or os.getenv("LOGNAME")
    use_launchctl = current_user != console_user

    debug_print("Restarting Dock...")
    try:
        if use_launchctl and user_uid:
            subprocess.run(
                ["launchctl", "asuser", str(user_uid), "killall", "Dock"],
                check=True,
                capture_output=True,
            )
        else:
            subprocess.run(["killall", "Dock"], check=True, capture_output=True)
        debug_print("Dock restarted successfully")
        return True
    except subprocess.CalledProcessError as e:
        error_print(f"Failed to restart Dock: {e}")
        return False


def get_user_uid(username):
    """Get user UID."""
    try:
        result = subprocess.run(
            ["id", "-u", username], capture_output=True, text=True, check=True
        )
        return int(result.stdout.strip())
    except (subprocess.CalledProcessError, ValueError):
        try:
            result = subprocess.run(
                ["dscl", ".", "-read", f"/Users/{username}", "UniqueID"],
                capture_output=True,
                text=True,
                check=True,
            )
            for line in result.stdout.split("\n"):
                if "UniqueID:" in line:
                    return int(line.split("UniqueID:")[1].strip())
        except (subprocess.CalledProcessError, ValueError):
            pass
    return None


def main():
    """Main function."""
    global DEBUG

    # Parse arguments
    args = sys.argv[1:]
    if "--debug" in args:
        DEBUG = True
        args.remove("--debug")

    # Get the current console user
    console_user = get_console_user()
    if not console_user:
        debug_print("No user logged in, skipping")
        sys.exit(1)

    # Get user home directory
    user_home = get_user_home(console_user)
    if not user_home:
        debug_print("Could not get user home directory")
        sys.exit(1)

    dock_plist = Path(user_home) / "Library" / "Preferences" / "com.apple.dock.plist"

    # Skip if dock plist doesn't exist
    if not dock_plist.exists():
        debug_print("Dock plist does not exist (user hasn't logged in yet)")
        sys.exit(1)

    debug_print(f"Dock plist: {dock_plist}")

    # Collect apps to add (only if they exist and aren't already in dock)
    apps_to_add = []
    debug_print(f"Processing {len(args)} argument(s)")

    for app_path_str in args:
        app_path = Path(app_path_str)
        debug_print(f"Checking app_path: {app_path}")

        if app_path.exists() or app_path.is_symlink():
            # Resolve symlinks to get the real path for validation
            resolved_path = Path(resolve_app_path(str(app_path)))
            debug_print(f"App path exists: {app_path} (resolved: {resolved_path})")

            # Verify it's a valid app bundle (has Contents/Info.plist)
            if app_path.suffix == ".app":
                info_plist = app_path / "Contents" / "Info.plist"
                resolved_info_plist = resolved_path / "Contents" / "Info.plist"
                if not info_plist.exists() and not resolved_info_plist.exists():
                    debug_print(
                        f"WARNING: App bundle appears invalid (no Info.plist): {app_path}"
                    )

            # Use the resolved path for the dock (dock needs the actual app location, not symlinks)
            app_url = get_app_url(str(resolved_path))
            debug_print(f"App URL: {app_url}")

            # Check if app is in dock and if it's valid
            is_in_dock, is_ghost = check_app_in_dock_status(dock_plist, app_url)

            if is_in_dock and not is_ghost:
                debug_print(
                    f"App already in dock with valid entry, skipping: {app_url}"
                )
                # Don't add it - it's already there and valid
                continue
            elif is_ghost:
                debug_print(f"Found ghost entry, removing before re-adding: {app_url}")
                # Remove ghost entry
                remove_app_from_dock(dock_plist, app_url)

            debug_print(f"Adding app to queue: {app_url}")
            apps_to_add.append(app_url)
        else:
            debug_print(f"App path does NOT exist: {app_path}")

    debug_print(f"Total apps to add: {len(apps_to_add)}")
    debug_print(f"Apps to add: {apps_to_add}")

    # If there are apps to add, append them to existing dock items
    if apps_to_add:
        user_uid = get_user_uid(console_user)
        debug_print(f"Console user: {console_user}")
        debug_print(f"User UID: {user_uid}")

        if user_uid:
            debug_print("Adding apps to dock...")
            current_user = os.getenv("USER") or os.getenv("LOGNAME")
            if current_user == console_user:
                debug_print("Running as console user, using defaults directly")
            else:
                debug_print("Running as different user, using launchctl asuser")

            # Add apps to dock
            success, changes_made = add_apps_to_dock(dock_plist, apps_to_add)
            if not success:
                error_print("Failed to add apps to dock")
                sys.exit(1)

            # Only restart dock if we actually made changes
            if changes_made:
                debug_print("Changes were made, restarting dock...")
                restart_dock(console_user, user_uid)
            else:
                debug_print("No changes were made, skipping dock restart")
        else:
            error_print("Could not get user UID")
            sys.exit(1)
    else:
        debug_print("No apps to add, skipping dock update")


if __name__ == "__main__":
    main()
