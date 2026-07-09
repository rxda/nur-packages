# NUR repository

Personal NUR repository skeleton.

## Layout

- `default.nix` - NUR entry point.
- `flake.nix` - flake entry point for local checks and development.
- `pkgs/` - packages exported by this repository.
- `lib/` - helper functions.
- `modules/` - NixOS modules.
- `overlays/` - overlays.

## Common commands

```sh
nix flake check
nix build .#hello-nur
nix build .#sing-box-beta
```

## Packages

- `bilibili-video-downloader`
- `hello-nur`
- `sing-box-beta`
- `tonghuashun`

`tonghuashun` is unfree and depends on OpenSSL 1.1, so consumers may need to set:

```nix
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
}
```
