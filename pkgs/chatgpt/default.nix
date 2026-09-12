{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  git,
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
          git
          xdg-utils
        ]
      }

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
