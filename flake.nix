{
  description = "Personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "openssl-1.1.1w"
            ];
          };
        };
        nurPkgs = import ./default.nix { inherit pkgs; };
      in
      {
        packages = {
          default = nurPkgs.hello-nur;
          bilibili-video-downloader = nurPkgs.bilibili-video-downloader;
          hello-nur = nurPkgs.hello-nur;
          sing-box-beta = nurPkgs.sing-box-beta;
          tonghuashun = nurPkgs.tonghuashun;
        };

        checks = {
          hello-nur = nurPkgs.hello-nur;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nixfmt
          ];
        };

        formatter = pkgs.nixfmt;
      }
    );
}
