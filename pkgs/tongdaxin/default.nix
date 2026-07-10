{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk2,
  gtk3,
  libdrm,
  libglvnd,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxtst,
  libxcb,
  mesa,
  nspr,
  nss,
  pango,
  procps,
  systemdLibs,
  wayland,
  zenity,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tongdaxin";
  version = "7.64";

  src = fetchurl {
    url = "https://data.tdx.com.cn/uos/com.tdx.tdxcfv_${finalAttrs.version}_amd64.deb";
    hash = "sha256-dXv/5pqE9xR6TvdhnJmCKCP5eXiJSAoIK5tgIj2GrbE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
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
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk2
    gtk3
    libdrm
    libglvnd
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxtst
    libxcb
    mesa
    nspr
    nss
    pango
    systemdLibs
    stdenv.cc.cc
    wayland
    zlib
  ];

  runtimeLibPath = lib.makeLibraryPath finalAttrs.buildInputs;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    appId="com.tdx.tdxcfv"
    appDir="$out/opt/apps/$appId"

    mkdir -p "$out/opt/apps" "$out/bin" "$out/share/applications" "$out/share/icons/hicolor/scalable/apps"
    cp -a "opt/apps/$appId" "$appDir"
    chmod -R u+w "$appDir"

    patchShebangs "$appDir/files/bin/tdxw.sh"

    install -Dm644 \
      "$appDir/entries/icons/hicolor/scalable/apps/$appId.svg" \
      "$out/share/icons/hicolor/scalable/apps/$appId.svg"

    install -Dm644 \
      "$appDir/entries/applications/$appId.desktop" \
      "$out/share/applications/$appId.desktop"
    substituteInPlace "$out/share/applications/$appId.desktop" \
      --replace-fail "/opt/apps/$appId/files/bin/tdxw.sh" "tdxcfv"

    makeWrapper "$appDir/files/bin/tdxw.sh" "$out/bin/tdxcfv" \
      --prefix PATH : "${
        lib.makeBinPath [
          procps
          zenity
        ]
      }" \
      --prefix LD_LIBRARY_PATH : "${finalAttrs.runtimeLibPath}:$appDir/files/bin:$appDir/files/lib64/tdx"

    runHook postInstall
  '';

  meta = {
    description = "TongDaXin financial terminal";
    homepage = "https://www.tdx.com.cn/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "tdxcfv";
    maintainers = [ ];
  };
})
