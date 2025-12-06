{self-lib, ...}: let
  inherit (self-lib) modules;
in {
  imports = map self-lib.mkConfiguration [
    {
      host = "empati";
      hostSuffix = "-macos";
      user = "ayik";
      system = "aarch64-darwin";
      modules =
        builtins.attrNames {inherit (modules) personal;};
    }
  ];
}
