{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "1.2.0";
  system = stdenv.hostPlatform.system;
  selectAsset =
    {
      x86_64-linux = {
        target = "linux-x64";
        hash = "sha256-bSqbPt3Q1ccMhbMjpSpYIqDqiR+AZAsIZqqgd5fYGcI=";
      };
      aarch64-linux = {
        target = "linux-arm64";
        hash = "sha256-J/MMXaqseFRObaaeUiTwi9DE0sQNq0nqlTULNIJRCC0=";
      };
      x86_64-darwin = {
        target = "darwin-x64";
        hash = "sha256-6a9QCEvEsSfvCXrdTQ0Ot71NF+V0wYi+28Fmaekht4s=";
      };
      aarch64-darwin = {
        target = "darwin-arm64";
        hash = "sha256-Qs8e3J8lzgvjoGh+ARUM60sjGy+PdXTJ+cKNXGapNxc=";
      };
    }
    .${system};
in
stdenv.mkDerivation {
  pname = "xata-cli";
  inherit version;

  src = fetchurl {
    url = "https://xata-cli-versions.s3.amazonaws.com/versions/${version}-latest/xata-${selectAsset.target}";
    inherit (selectAsset) hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/xata
    runHook postInstall
  '';

  meta = {
    description = "Xata CLI";
    homepage = "https://xata.io/docs/cli";
    mainProgram = "xata";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
