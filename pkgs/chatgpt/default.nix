{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  bash,
  bubblewrap,
  coreutils,
  dejavu_fonts,
  dpkg,
  gh,
  git,
  makeFontsConf,
  makeWrapper,
  xdg-utils,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libglvnd,
  libnotify,
  nss,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  mesa,
  pango,
  perl,
  qt5,
  qt6Packages,
  systemdLibs,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chatgpt";
  version = "26.908.40834";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
    hash = "sha256-2je457zvquoBnEeMrL5sc+4d3RXg4euzx+8KQt2BisI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    perl
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libglvnd
    libnotify
    nss
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    mesa
    pango
    qt5.qtbase.out
    qt6Packages.qtbase.out
    stdenv.cc.cc
    systemdLibs
    zlib
  ];

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  fontconfigConf = makeFontsConf {
    fontDirectories = [ dejavu_fonts ];
  };

  runtimeLibPath = lib.makeLibraryPath [
    libglvnd
    mesa
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a usr/lib usr/share "$out/"
    mkdir -p "$out/bin"

    makeWrapper "$out/lib/chatgpt/codex-launcher" "$out/bin/chatgpt" \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          bubblewrap
          coreutils
          gh
          git
          xdg-utils
        ]
      } \
      --run "if [ -d \"\$HOME/.codex/.tmp/bundled-marketplaces\" ]; then chmod -R u+rwX \"\$HOME/.codex/.tmp/bundled-marketplaces\" 2>/dev/null || true; fi; if [ -d \"\$HOME/.codex/plugins/cache\" ]; then chmod -R u+rwX \"\$HOME/.codex/plugins/cache\" 2>/dev/null || true; fi; if [ -z \"\$CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH\" ]; then cache_root=\"\$HOME/.cache\"; if [ -n \"\$XDG_CACHE_HOME\" ]; then cache_root=\"\$XDG_CACHE_HOME\"; fi; cache_dir=\"\$cache_root/chatgpt\"; source_dir=\"$out/lib/chatgpt/resources\"; stamp=\"\$cache_dir/.bundled-plugins-${finalAttrs.version}\"; if [ ! -f \"\$stamp\" ]; then mkdir -p \"\$cache_dir/plugins\"; rm -rf \"\$cache_dir/plugins/openai-bundled\"; cp -R \"\$source_dir/plugins/openai-bundled\" \"\$cache_dir/plugins/\"; chmod -R u+rwX \"\$cache_dir/plugins/openai-bundled\"; : > \"\$stamp\"; fi; export CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH=\"\$cache_dir\"; fi" \
      --set FONTCONFIG_FILE "${finalAttrs.fontconfigConf}" \
      --prefix LD_LIBRARY_PATH : "${finalAttrs.runtimeLibPath}"

    # The Linux git watcher triggers a crash in Electron's Node report API.
    # The application falls back to getconf/ldd when this report is empty.
    # Keep the replacement the same length so ASAR offsets remain valid.
    perl -pi -e 's/report = process\.report\.getReport\(\);/sprintf("%-36s", "report = {};")/ge' \
      "$out/lib/chatgpt/resources/app.asar"

    # Electron calculates x/y for the primary window, but Wayland compositors
    # may ignore explicit coordinates. Use Electron's native centering option
    # for a new primary window, or a stale Wayland (0,0) restore; keep other
    # restored bounds untouched. The available
    # macOS-only hasNativeGlass field provides an equal-size replacement, so
    # ASAR offsets remain valid without repacking the 300+ MiB archive.
    perl -pi -e 's/hasNativeGlass:process\.platform===`darwin`&&o===`avatarOverlay`,/("center:y&&(b==null||b.x===0&&b.y===0)," . (" " x 26))/e' \
      "$out/lib/chatgpt/resources/app.asar"

    runHook postInstall
  '';

  meta = {
    description = "Official ChatGPT desktop application by OpenAI";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt";
    maintainers = with lib.maintainers; [ rxda ];
  };
})
