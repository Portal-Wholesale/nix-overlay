{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.20.0";
  sources = {
    aarch64-darwin = {
      asset = "crit-darwin-arm64";
      hash = "sha256-3o5u3R6hRsV+4P2k8qYJ6eEYVHSrpwgbC0qTRZ16IjE=";
    };
    x86_64-darwin = {
      asset = "crit-darwin-amd64";
      hash = "sha256-F37KJdD021H4Z6N3+kdzuZsmfifTzsQT/HVrra47Qeo=";
    };
    aarch64-linux = {
      asset = "crit-linux-arm64";
      hash = "sha256-hsb6+SJdUq8RyfgqvZrvZZyee2o4YVuXv8qHSDpTsDY=";
    };
    x86_64-linux = {
      asset = "crit-linux-amd64";
      hash = "sha256-KMuw9oVf6kkHfTrcL+Y5KnAFjkF+5DXP4n5Xkr14WW0=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "crit";
  inherit version;

  src = fetchurl {
    url = "https://github.com/tomasz-tomczyk/crit/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/crit
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/crit --version | grep -F ${lib.escapeShellArg version}
  '';

  meta = {
    description = "Local review and feedback loop for coding agents";
    homepage = "https://github.com/tomasz-tomczyk/crit";
    changelog = "https://github.com/tomasz-tomczyk/crit/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "crit";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
