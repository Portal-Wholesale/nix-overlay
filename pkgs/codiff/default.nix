{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  unzip,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  systemd,
  xdg-utils,
}:

let
  version = "1.12.1";
  sources = {
    aarch64-darwin = {
      asset = "Codiff-darwin-arm64-${version}.zip";
      hash = "sha256-8tROjpqSxhXLnA7rq3r/msaVjf4cqu0S2xHumT06GHw=";
    };
    x86_64-linux = {
      asset = "codiff_${version}_amd64.deb";
      hash = "sha256-StCYaVf9omNlQhAwJTxpxMbqv//VCh7ZwxcOpenam6o=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "codiff";
  inherit version;

  src = fetchurl {
    url = "https://github.com/nkzw-tech/codiff/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs =
    if stdenv.hostPlatform.isLinux then
      [
        autoPatchelfHook
        dpkg
        wrapGAppsHook3
      ]
    else
      [
        unzip
      ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    systemd
  ];

  gappsWrapperArgs = lib.optionals stdenv.hostPlatform.isLinux [
    "--suffix PATH : ${lib.makeBinPath [ xdg-utils ]}"
  ];

  unpackPhase =
    if stdenv.hostPlatform.isLinux then
      ''
        dpkg-deb -x $src .
      ''
    else
      ''
        unzip -q $src
      '';

  installPhase =
    if stdenv.hostPlatform.isLinux then
      ''
        runHook preInstall
        mkdir -p $out/bin $out/lib $out/share
        cp -r usr/lib/codiff $out/lib/
        cp -r usr/share/* $out/share/
        ln -s ../lib/codiff/codiff $out/bin/codiff
        runHook postInstall
      ''
    else
      ''
        runHook preInstall
        mkdir -p $out/Applications $out/bin
        cp -r Codiff.app $out/Applications/
        ln -s ../Applications/Codiff.app/Contents/Resources/app/bin/codiff-app $out/bin/codiff
        grep -F ${lib.escapeShellArg ''"version": "${version}"''} \
          $out/Applications/Codiff.app/Contents/Resources/app/package.json
        runHook postInstall
      '';

  dontStrip = stdenv.hostPlatform.isDarwin;
  dontPatchShebangs = stdenv.hostPlatform.isDarwin;

  doInstallCheck = stdenv.hostPlatform.isLinux;
  installCheckPhase = ''
    $out/bin/codiff --version | grep -F ${lib.escapeShellArg version}
  '';

  meta = {
    description = "Fast local diff viewer";
    homepage = "https://github.com/nkzw-tech/codiff";
    changelog = "https://github.com/nkzw-tech/codiff/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "codiff";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
