{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "idb-companion";
  version = "1.6.0";

  # Prebuilt release binary. Building idb_companion from source needs a full
  # Xcode toolchain plus unpinned SwiftPM/grpc-swift checkouts, which is not
  # reproducible in the Nix sandbox (see the upstream Homebrew formula notes).
  src = fetchurl {
    url = "https://github.com/facebook/idb/releases/download/v${finalAttrs.version}/idb-companion.macos-arm64.tar.gz";
    hash = "sha256-GCGZBmrQC/KI88++jADsyxw6df1RHko2Z9bMGlwjxWk=";
  };

  sourceRoot = ".";

  # Apple-signed Mach-O binaries and Swift resource bundles: keep the tree
  # byte-for-byte intact so the code signature and @executable_path lookups
  # keep working.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    # idb_companion resolves Resources/ and the SwiftPM bundles as siblings of
    # its own binary and aborts when they are missing, so install the whole
    # archive under libexec and symlink the executables into bin.
    mkdir -p $out/libexec/idb-companion $out/bin
    cp -R . $out/libexec/idb-companion/

    for exe in idb_companion idb-repl; do
      test -x "$out/libexec/idb-companion/$exe" \
        || { echo "$exe missing from the release archive: layout changed" >&2; exit 1; }
      ln -s "$out/libexec/idb-companion/$exe" "$out/bin/$exe"
    done

    runHook postInstall
  '';

  meta = {
    description = "Companion server for automating iOS Simulators (idb)";
    longDescription = ''
      Runtime requirements: macOS 15+ and a selected Xcode 26 developer
      directory (CoreSimulator is loaded from DEVELOPER_DIR at runtime).
    '';
    homepage = "https://fbidb.io";
    changelog = "https://github.com/facebook/idb/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "idb_companion";
  };
})
