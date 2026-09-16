{
  lib,
  stdenv,
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
    hash = "sha256-FkexXPBmafoOqkrs9L4YPLGyP+A97CdYQMXvRZtWwWk=";
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
    makeWrapper "$out/lib/deepseek-harness/apps/cli/lib/bin.js" "$out/bin/dsh" \
      --prefix PATH : ${lib.makeBinPath [ nodejs_22 ]}
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
