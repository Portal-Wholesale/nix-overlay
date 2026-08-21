{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.19.1";
  releases = {
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-B2U2IAGZVAUV69+Sn3yz9BPYK+NSR3GipZdbgMqF1yc=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-xiJpDyxwN+ET6UQRMR/n9xWGkvjgSNdf3exuKTOWgig=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-gnu";
      hash = "sha256-mwgEky8BHuE3CdBqNCzX0wIip2S7YtNDdxlkRxsqfiU=";
    };
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-mgtYglMvX/uxxofZKE+oBBlJlisF8U/BMQUPhscOHvw=";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "secretspec";
  inherit version;

  src = fetchurl {
    url = "https://github.com/cachix/secretspec/releases/download/v${version}/secretspec-${release.target}.tar.xz";
    inherit (release) hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 secretspec $out/bin/secretspec
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/secretspec --version | grep -F ${lib.escapeShellArg version}
  '';

  meta = {
    description = "Declarative secrets management";
    homepage = "https://github.com/cachix/secretspec";
    license = lib.licenses.asl20;
    mainProgram = "secretspec";
    platforms = builtins.attrNames releases;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
