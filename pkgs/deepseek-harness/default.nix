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
  version = "0.1.0-rc.5";

  src = fetchFromGitHub {
    owner = "deepseek-ai";
    repo = "deepseek-harness";
    rev = "47f943859bef60e4160492346772ded9b24f765a";
    hash = "sha256-ZPGCNoPXVjP76Tm/tFPDX2X95cd83M4iHLmVP5dR+Ps=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-aySHq0ywTMM5q7YuGHZrV3yQE3bwppgGfWH3wRnHCXk=";
  };

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
