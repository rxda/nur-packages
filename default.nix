{
  pkgs ? import <nixpkgs> { },
}:

let
  callPackage = pkgs.callPackage;
in
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  bilibili-video-downloader = callPackage ./pkgs/bilibili-video-downloader { };
  hello-nur = callPackage ./pkgs/hello-nur { };
  sing-box-beta = callPackage ./pkgs/sing-box-beta { };
  tonghuashun = callPackage ./pkgs/tonghuashun { };
}
