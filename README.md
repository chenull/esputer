<img src="files/es-dong-dong-s.png" alt="Es Dong Dong" width="160">

# Es Puter Nix Configuration

>
> _`es puter` is a traditional ice cream sold by mang es krim across Indonesia's streets. `esputer` is where the s class in computer_
>

A modular Nix flake configuration for managing multiple hosts across different architectures (NixOS and nix-darwin).

Mostly taken from `@enzime`'s [Nix config repo](https://github.com/enzime/dotfiles-nix/)

## Overview

This repository contains a unified Nix configuration that supports:
- **NixOS** (Linux) systems
- **nix-darwin** (macOS) systems
- **Home Manager** for user-specific configurations
- Modular configuration system for easy maintenance

## Structure

```
.
├── flake.nix              # Main flake definition
├── lib.nix                # Library functions for configuration generation
├── hosts/                 # Host-specific configurations
│   ├── hosts.nix          # Host definitions
│   ├── empati/            # macOS host (aarch64-darwin)
│   │   ├── darwin-configuration.nix
│   │   └── home.nix
│   └── solong/            # Linux host (x86_64-linux)
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── home.nix
├── modules/               # Reusable configuration modules
│   ├── base.nix          # Base system configuration
│   ├── personal.nix       # Personal modules
│   ├── terminal.nix      # Terminal configuration
│   ├── flakes.nix        # Flake-related configuration
│   └── skeleton.nix      # Skeleton/template module
└── overlays/              # Nixpkgs overlays
    └── neovim.nix
```

## Features

- **Multi-architecture support**: Configure hosts with different architectures (x86_64-linux, aarch64-darwin)
- **Modular design**: Reusable modules that can be shared across hosts
- **Automatic module discovery**: Modules are automatically discovered from the `modules/` directory
- **Home Manager integration**: User configurations managed through Home Manager
- **Flake-parts**: Organized using flake-parts for better structure

## Prerequisites

- Nix with flakes enabled
- For NixOS: A NixOS system
- For macOS: nix-darwin installed

## Usage

### Building Configurations

Build a specific host configuration:

```bash
# For NixOS
nix build .#nixosConfigurations.solong.config.system.build.toplevel

# For nix-darwin
nix build .#darwinConfigurations.empati.system

# For Home Manager
nix build .#homeConfigurations."ayik@empati".activationPackage
```

### Applying Configurations

```bash
# NixOS
sudo nixos-rebuild switch --flake .#solong

# nix-darwin
darwin-rebuild switch --flake .#empati

# Home Manager
home-manager switch --flake .#"ayik@empati"
```

### Development Shell

Enter the development shell:

```bash
nix develop
```

### Checking the Flake

Validate the flake configuration:

```bash
nix flake check
```

## Adding a New Host

1. Create a new directory under `hosts/`:
   ```bash
   mkdir -p hosts/newhost
   ```

2. Create the host configuration files:
   - For NixOS: `configuration.nix` and optionally `hardware-configuration.nix`
   - For macOS: `darwin-configuration.nix`
   - Create `home.nix` for user configuration

3. Add the host to `hosts/hosts.nix`:
   ```nix
   {
     host = "newhost";
     hostSuffix = "";
     user = "yourusername";
     system = "x86_64-linux";  # or "aarch64-darwin"
     modules = builtins.attrNames {inherit (modules) personal;};
   }
   ```

## Creating Modules

Modules are automatically discovered from the `modules/` directory. Each module should export:

- `nixosModule`: For NixOS systems
- `darwinModule`: For nix-darwin systems
- `homeModule`: For Home Manager configurations

Example module structure:

```nix
{...}: {
  nixosModule = {...}: {
    # NixOS configuration
  };
  
  darwinModule = {...}: {
    # nix-darwin configuration
  };
  
  homeModule = {...}: {
    # Home Manager configuration
  };
}
```

Modules can also declare dependencies through an `imports` attribute:

```nix
{
  imports = ["base"];
  # ... module configuration
}
```

## Inputs

This flake uses the following inputs:

- `nixpkgs`: NixOS/nixpkgs (unstable)
- `flake-parts`: Flake organization framework
- `nix-darwin`: macOS system configuration
- `home-manager`: User environment management
- `utils`: flake-utils-plus for additional utilities

## License

Any
