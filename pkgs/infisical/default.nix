{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  testers,
}:

let
  version = "0.43.104";

  sources = {
    x86_64-linux = {
      target = "linux_amd64";
      hash = "sha256-zQ/vQvXCNxuEB8acl8mTl4+Amb1Y7IdZDlV5NZRUCCw=";
    };
    aarch64-linux = {
      target = "linux_arm64";
      hash = "sha256-kii6k2Egi2+QyXd9hFjk8c3pxj7euSzIiWYv1rPfWN8=";
    };
    x86_64-darwin = {
      target = "darwin_amd64";
      hash = "sha256-JSLHPN2+uBBvDpiQ6YLFo/L9f39vEmwqS2qPeTsmcv4=";
    };
    aarch64-darwin = {
      target = "darwin_arm64";
      hash = "sha256-pSz8Pm/Q2SMs0VwMX+fc2rkV223PYu9GMgpKm/5Fw9E=";
    };
  };

  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "infisical";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Infisical/cli/releases/download/v${version}/cli_${version}_${source.target}.tar.gz";
    inherit (source) hash;
  };

  nativeBuildInputs = [ installShellFiles ];

  sourceRoot = ".";
  dontBuild = true;
  dontStrip = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ./infisical --version
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 infisical $out/bin/infisical
    installManPage manpages/infisical.1.gz
    installShellCompletion completions/infisical.{bash,fish,zsh}
    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Official CLI for Infisical";
    homepage = "https://infisical.com";
    changelog = "https://github.com/Infisical/cli/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "infisical";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
