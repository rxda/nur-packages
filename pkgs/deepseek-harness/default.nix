{
  lib,
  stdenv,
  bubblewrap,
  musl,
  fetchFromGitHub,
  nodejs_22,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
  python3,
  pkg-config,
  node-gyp,
}:

let
  pnpm = pnpm_11.override { nodejs-slim = nodejs_22; };

  # Directory of the per-platform npm package that carries the native
  # binaries. Upstream names these after Node's architecture labels.
  nativePlatformDir =
    if stdenv.hostPlatform.isx86_64 then
      "linux-x64"
    else if stdenv.hostPlatform.isAarch64 then
      "linux-arm64"
    else
      throw "deepseek-harness: unsupported platform ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "deepseek-harness";
  version = "0.1.6-alpha.1";

  src = fetchFromGitHub {
    owner = "deepseek-ai";
    repo = "deepseek-harness";
    rev = "0a15e36e7f82b6ed45af6fa9759f29b40dcd965d";
    hash = "sha256-vlCnBbaUPtMBs+9do1QQ/71bWkgxOTXlP27CZeCRbCI=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-DNGGgnec3hFUs3LDorlUGzzgRT88i33y8TqyXfoXVnY=";
  };

  # fetchFromGitHub provides a source archive without Git metadata, while the
  # upstream client build embeds the source commit in generated artifacts.
  DSH_CLIENT_COMMIT_HASH = "0a15e36e7f82b6ed45af6fa9759f29b40dcd965d";

  nativeBuildInputs = [
    nodejs_22
    pnpm
    pnpmConfigHook
    makeWrapper
    python3
    pkg-config
    node-gyp
  ];

  buildPhase = ''
    runHook preBuild
    pnpm run build
    (
      cd node_modules/.pnpm/node-pty@*/node_modules/node-pty
      node-gyp rebuild --nodedir=${nodejs_22}
    )

    # `pnpm run build` builds the native system bindings through
    # `native/system/scripts/build.ts --host-addon-only`, which skips every
    # non-Node-API binary.  `landlock-run` is declared `static-musl`, so it is
    # never produced: the install ships flock's `system.node` but no launcher,
    # and `dsh` then fails closed with "no sandbox backend is usable on this
    # host", refusing to run even read-only commands.  Build the launcher here
    # from its upstream source.  It is plain C11 over the raw Landlock UAPI
    # with no dependency beyond libc, and upstream links it statically with
    # musl; nixpkgs ships that same wrapper as `musl-gcc` (in musl's `dev`
    # output).
    mkdir -p native/system/packages/${nativePlatformDir}/bin
    ${lib.getDev musl}/bin/musl-gcc \
      -std=c11 -Os -Wall -Wextra -Werror -static -no-pie -s \
      -o native/system/packages/${nativePlatformDir}/bin/landlock-run \
      native/system/packages/entry/src/main.c

    runHook postBuild
  '';

  dontPatchShebangs = true;
  dontStrip = true;
  dontCheckForBrokenSymlinks = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib"
    cp -r . "$out/lib/deepseek-harness"
    patchShebangs "$out/lib/deepseek-harness/apps/cli/lib/bin.js"
    # The upstream loader uses Node's internal ESM resolver to resolve plugins
    # from the profile directory.  Without this flag, node-addon-require-builtin
    # cannot expose that resolver on Nix's Node build and every bare plugin
    # import is attempted relative to cordis-plugin-loader instead.

    # `dsh` probes its Linux backend chain in preference order: bwrap, then the
    # Landlock launcher built above.  bwrap is preferred because it also gives
    # the command a private mount and PID namespace, while Landlock governs file
    # effects only.  Put bwrap on the wrapper's PATH so the sandbox does not
    # depend on each consumer installing it; selection stays probe-based, so a
    # host that cannot use bwrap (e.g. unprivileged user namespaces disabled)
    # still falls back to Landlock rather than failing.
    makeWrapper ${nodejs_22}/bin/node "$out/bin/dsh" \
      --add-flags "--expose-internals $out/lib/deepseek-harness/apps/cli/lib/bin.js" \
      --prefix PATH : ${lib.makeBinPath [ nodejs_22 bubblewrap ]}
    runHook postInstall
  '';

  meta = {
    description = "Plugin-based agent harness by DeepSeek AI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ rxda ];
    mainProgram = "dsh";
  };
})
