# Module: zsh
let
  shared = {...}: {
    programs.zsh = {
      enable = true;
      shellInit = ''
        eval "zigfetch"
      '';
    };
  };
in {
  # Darwin configuration.
  darwinModule = {...}: {
    imports = [shared];
  };
  # NixOS configuration.
  nixosModule = {...}: {
    imports = [shared];
  };

  # Home configuration.
  homeModule = {
    pkgs,
    lib,
    ...
  }: {
    programs.zsh = {
      enable = true;
      # If this option is not disabled
      # `home-manager` installs `nix-zsh-completions`
      # which conflicts with `nix` in `home.packages`
      enableCompletion = false;

      # TODO:
      # eval "$(/opt/homebrew/bin/brew shellenv)"
      # eval "$(direnv hook zsh)"
      # eval "$(zoxide init zsh)"
      # eval "$(starship init zsh)"

      prezto = {
        enable = true;

        pmoduleDirs = ["${pkgs.zsh-you-should-use}/share/zsh/plugins"];

        pmodules = [
          "environment"
          "terminal"
          "you-should-use"
          "editor"
          "history"
          "directory"
          "spectrum"
          # `git` just needs to be before `completion`
          "git"
          "completion"
          "prompt"
        ];
      };

      history = {
        extended = true;
        save = 1000000;
        size = 1000000;
        ignoreSpace = true;
        ignoreDups = true;
        expireDuplicatesFirst = true;
      };

      initContent =
        lib.readFile ../files/zshrc
        + ''
          if [[ -d ~/.hishtory ]]; then
            source ${pkgs.hishtory}/share/hishtory/config.zsh
          fi
        '';

      shellAliases = {
        arg = "alias | rg --";
        l = "ls -lah";
        wh = "where -s";
      };
    };
  };
}
