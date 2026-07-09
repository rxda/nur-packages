{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  dpkg,
  makeFontsConf,
  makeDesktopItem,
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
  gtk3,
  icu,
  dejavu_fonts,
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
  lttng-ust_2_12,
  mesa,
  nspr,
  nss,
  noto-fonts-cjk-sans,
  openssl_1_1,
  pango,
  systemdLibs,
  wayland,
  wqy_microhei,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tonghuashun";
  version = "2.9.1.0";

  src = fetchurl {
    url = "https://sp.thsi.cn/staticS3/mobileweb-upload-static-server.file/app_6/downloadcenter/cn.com.10jqka_2.9.1.0_amd64.deb";
    hash = "sha256-77wsPJ4KrUUJJzD5/0HlN7wOSNKwfwnHBJMB4A3goU4=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
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
    gtk3
    icu
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
    lttng-ust_2_12.out
    mesa
    nspr
    nss
    openssl_1_1
    pango
    systemdLibs
    stdenv.cc.cc
    wayland
    zlib
  ];

  runtimeLibPath = lib.makeLibraryPath finalAttrs.buildInputs;

  fontconfigConf = makeFontsConf {
    fontDirectories = [
      dejavu_fonts
      noto-fonts-cjk-sans
      wqy_microhei
    ];
  };

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    appDir="$out/opt/apps/cn.com.10jqka"

    mkdir -p "$out/opt/apps" "$out/bin" "$out/share/icons/hicolor/scalable/apps"
    cp -a opt/apps/cn.com.10jqka "$appDir"
    chmod -R u+w "$appDir"

    install -Dm644 \
      "$appDir/entries/icons/hicolor/scalable/apps/HevoIcon.svg" \
      "$out/share/icons/hicolor/scalable/apps/cn.com.10jqka.svg"

    makeWrapper "$appDir/files/HevoNext.B2CApp" "$out/bin/10jqka" \
      --set FONTCONFIG_FILE "${finalAttrs.fontconfigConf}" \
      --prefix LD_LIBRARY_PATH : "${finalAttrs.runtimeLibPath}:$appDir/files:$appDir/files/lib:$appDir/files/cef/Release:$appDir/files/cef/Release/swiftshader"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "cn.com.10jqka";
      desktopName = "同花顺Linux";
      genericName = "Stock trading client";
      comment = "提供最全面的行情信息";
      exec = "10jqka %U";
      icon = "cn.com.10jqka";
      terminal = false;
      categories = [
        "Office"
        "Finance"
      ];
      startupWMClass = "HevoNext.B2CApp";
    })
  ];

  meta = {
    description = "Tonghuashun stock market and trading client for Linux";
    homepage = "https://www.10jqka.com.cn/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "10jqka";
    maintainers = [ ];
  };
})
