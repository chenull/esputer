# Module: ghostty terminal emulator
{
  homeModule = {
    pkgs,
    lib,
    ...
  }: {
    # TODO: move this ?
    programs.ghostty.enable = true;

    programs.ghostty.package =
      if pkgs.stdenv.hostPlatform.isDarwin
      then pkgs.ghostty-bin
      else pkgs.ghostty;

    programs.ghostty.settings = {
      theme = "Starlight";
      bold-is-bright = true;
      quit-after-last-window-closed = true;
      auto-update = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "off";
      keybind = "shift+enter=text:\\n";
    };
  };
}
