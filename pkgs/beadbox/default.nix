{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  upx,
  wrapGAppsHook3,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gtk3,
  libsoup_3,
  webkitgtk_4_1,
  libayatana-appindicator,
  xdg-utils,
}:

let
  version = "0.27.2";
  sources = {
    aarch64-darwin = {
      asset = "Beadbox_aarch64.app.tar.gz";
      hash = "sha256-i6ez8sC1tBxPFigDwBnkXMDV/DODcvg+iVOd0fFStNY=";
    };
    x86_64-linux = {
      asset = "beadbox_${version}_Linux_amd64.deb";
      hash = "sha256-KMthCC/bDmrIIts3JQ8z4gWBTRvCybBztuJnqb9QbNo=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "beadbox";
  inherit version;

  src = fetchurl {
    url = "https://github.com/beadbox/beadbox/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    dpkg
    upx
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    cairo
    dbus
    gdk-pixbuf
    glib
    gtk3
    libsoup_3
    webkitgtk_4_1
    libayatana-appindicator
    stdenv.cc.cc.lib
  ];

  gappsWrapperArgs = lib.optionals stdenv.hostPlatform.isLinux [
    "--suffix PATH : ${lib.makeBinPath [ xdg-utils ]}"
  ];

  unpackPhase = ''
    runHook preUnpack
    ${
      if stdenv.hostPlatform.isLinux then
        ''dpkg-deb --fsys-tarfile "$src" | tar --no-same-owner --no-same-permissions -xf -''
      else
        ''tar -xzf "$src"''
    }
    runHook postUnpack
  '';

  # The release sidecar is UPX-compressed; expose its ELF headers for patchelf.
  postUnpack = lib.optionalString stdenv.hostPlatform.isLinux ''
    upx -d usr/bin/beadbox-sidecar
  '';

  installPhase = ''
    runHook preInstall
    ${
      if stdenv.hostPlatform.isLinux then
        ''
          mkdir -p "$out/bin" "$out/share"
          cp -r usr/bin/* "$out/bin/"
          cp -r usr/share/* "$out/share/"
        ''
      else
        ''
          mkdir -p "$out/Applications" "$out/bin"
          cp -r Beadbox.app "$out/Applications/"
          ln -s ../Applications/Beadbox.app/Contents/MacOS/beadbox "$out/bin/beadbox"
        ''
    }
    runHook postInstall
  '';

  # Preserve the signed macOS bundle and the Bun sidecar's embedded payload.
  dontStrip = true;
  dontPatchShebangs = stdenv.hostPlatform.isDarwin;

  meta = {
    description = "Native desktop GUI for the beads issue tracker";
    longDescription = ''
      Beadbox provides a visual interface to beads workspaces. It requires
      a separately installed beads CLI (bd), version 1.1.0 or newer, available
      on PATH or selected with the BD_PATH environment variable.
    '';
    homepage = "https://github.com/beadbox/beadbox";
    changelog = "https://github.com/beadbox/beadbox/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "beadbox";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
