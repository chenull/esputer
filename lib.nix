{lib}: let
  inherit (builtins) readDir;
  inherit (lib.path) removePrefix;
  inherit
    (lib)
    concatMap
    filter
    filterAttrs
    getAttr
    hasAttr
    hasSuffix
    mapAttrs'
    nameValuePair
    optionalAttrs
    removeSuffix
    unique
    ;

  importFrom = path: filename: import (path + ("/" + filename));

  pathTo = path: ./. + "/${removePrefix ./. path}";

  # TODO: overlays

  # get modules from ./modules
  modules' =
    mapAttrs' (
      filename: _:
        nameValuePair (removeSuffix ".nix" filename)
        (importFrom (pathTo ./modules) filename)
    ) (
      filterAttrs (_: type: type == "regular") (readDir (pathTo ./modules))
    );

  getModuleList = a: let
    imports =
      if (modules'.${a} ? imports)
      then modules'.${a}.imports
      else [];
  in
    if (imports == [])
    then [a]
    else [a] ++ unique (concatMap getModuleList imports);

  mkConfiguration = {
    host,
    hostSuffix ? "",
    user,
    system,
    nixos ? hasSuffix "linux" system,
    modules,
    # TODO: tags
    tags ? [],
  }: {
    self,
    inputs,
    lib,
    ...
  }: let
    nixpkgs = {
      config.allowUnfree = true;
      hostPlatform = system;
    };

    isDarwin = hasSuffix "darwin" system;

    # Ensure modules/base.nix exists
    moduleList =
      if hasAttr "base" modules'
      then unique (concatMap getModuleList (["base"] ++ modules))
      else throw "modules/base.nix is required but does not exist";
    modulesToImport = map (name: getAttr name modules') moduleList;

    hostname = "${host}${hostSuffix}";
    nixosModules =
      map (getAttr "nixosModule")
      (filter (hasAttr "nixosModule") modulesToImport);
    homeModules =
      map (getAttr "homeModule")
      (filter (hasAttr "homeModule") modulesToImport);
    darwinModules =
      map (getAttr "darwinModule")
      (filter (hasAttr "darwinModule") modulesToImport);
    home =
      [
        (pathTo ./hosts/${host}/home.nix)
      ]
      ++ homeModules;

    configRevision = {
      full = self.rev or self.dirtyRev or "dirty-inputs";
      short = self.shortRev or self.dirtyShortRev or "dirty-inputs";
    };
    # TODO: keys

    extraHomeManagerArgs = {inherit inputs configRevision moduleList;};
  in {
    # nix build .#nixosConfigurations.${hostname}.config.system.build.toplevel
    # OR
    # nixos-rebuild build --flake .#${hostname}
    flake.nixosConfigurations = lib.mkMerge [
      (lib.mkIf nixos {
        ${hostname} = inputs.nixpkgs.lib.nixosSystem {
          modules =
            [
              {
                nixpkgs.config = nixpkgs.config;
                nixpkgs.hostPlatform = nixpkgs.hostPlatform;
              }
              inputs.utils.nixosModules.autoGenFromInputs
              (pathTo ./hosts/${host}/configuration.nix)
            ]
            ++ nixosModules
            ++ [
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;

                # `home-manager` uses `/etc/profiles/per-user/` instead of `~/.nix-profile`
                # Required for `fonts.fontconfig.enable = true;`
                home-manager.useUserPackages = true;

                home-manager.users.${user}.imports = home;
                home-manager.extraSpecialArgs = extraHomeManagerArgs;
              }
            ];
          specialArgs = {
            inherit inputs configRevision user host hostname;
          };
        };
      })
    ];

    # nix build .#darwinConfigurations.${hostname}.system
    # OR
    # darwin-rebuild build --flake .#${hostname}
    flake.darwinConfigurations = lib.mkMerge [
      (lib.mkIf isDarwin {
        ${hostname} = inputs.nix-darwin.lib.darwinSystem {
          inherit inputs;
          system = nixpkgs.hostPlatform;
          modules =
            [
              # inputs.utils.darwinModules.autoGenFromInputs
              (pathTo ./hosts/${host}/darwin-configuration.nix)
            ]
            ++ darwinModules
            ++ [
              inputs.home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.users.${user} = {
                  imports = home;
                  home.homeDirectory = lib.mkForce "/Users/${user}";
                };
                home-manager.extraSpecialArgs = extraHomeManagerArgs;
              }
            ];
          specialArgs = {inherit configRevision user host hostname;};
        };
      })
    ];

    # nix build .#homeConfigurations."${user}@${hostname}".activationPackage
    # OR
    # home-manager build --flake .#"${user}@${hostname}"
    flake.homeConfigurations."${user}@${hostname}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules =
        [
          ({pkgs, ...}: {
            home.username = user;
            home.homeDirectory =
              if pkgs.stdenv.hostPlatform.isDarwin
              then "/Users/${user}"
              else "/home/${user}";
          })
        ]
        ++ home;
      extraSpecialArgs = extraHomeManagerArgs;
    };

    flake.checks.${system} =
      (optionalAttrs nixos {
        "nixos-${hostname}" =
          self.nixosConfigurations.${hostname}.config.system.build.toplevel;
      })
      // (optionalAttrs isDarwin {
        "nix-darwin-${hostname}" =
          self.darwinConfigurations.${hostname}.config.system.build.toplevel;
      })
      // {
        "home-manager-${user}@${hostname}" =
          self.homeConfigurations."${user}@${hostname}".activationPackage;
      };
  };
in {
  inherit mkConfiguration pathTo;
  modules = modules';
}
