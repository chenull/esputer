{self-lib, ...}: let
  inherit (self-lib) modules;
in {
  imports = map self-lib.mkConfiguration [
    {
      host = "empati";
      hostSuffix = "";
      user = "ayik";
      system = "aarch64-darwin";
      modules = builtins.attrNames {
        inherit
          (modules)
          personal
          laptop
          macos
          graphical
          ;
      };
    }
    {
      host = "solong";
      hostSuffix = "";
      user = "ayik";
      system = "x86_64-linux";
      modules = builtins.attrNames {
        inherit
          (modules)
          personal
          laptop
          graphical
          niri
          ;
      };
    }
  ];
}
