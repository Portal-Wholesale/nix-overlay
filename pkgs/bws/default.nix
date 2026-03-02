{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  version = "2.0.0";
  system = stdenv.hostPlatform.system;
  selectAsset =
    {
      x86_64-linux = {
        url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v${version}/bws-x86_64-unknown-linux-musl-${version}.zip";
        hash = "sha256-6m6xjxJwOI8S0Vo1+RnMs0iNMqd3Qzuu/og9Vh9G/HM=";
      };
      aarch64-linux = {
        url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v${version}/bws-aarch64-unknown-linux-musl-${version}.zip";
        hash = "sha256-3mG/usvPbjZI3cjb1sqLsiRUOMz1+U1UEpmXUo9adS0=";
      };
      x86_64-darwin = {
        url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v${version}/bws-x86_64-apple-darwin-${version}.zip";
        hash = "sha256-LzP6faPXw+4YOPPF8+ikcFHj/bAcRXAfaET6CzROktE=";
      };
      aarch64-darwin = {
        url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v${version}/bws-aarch64-apple-darwin-${version}.zip";
        hash = "sha256-W7tD/Ox1UoxdeOTf2yK2s2js3/cCC82FORFWRYf2H4o=";
      };
    }
    .${system};
in
stdenv.mkDerivation {
  pname = "bws";
  inherit version;

  src = fetchurl {
    inherit (selectAsset) url hash;
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";
  unpackCmd = "unzip $curSrc -d .";

  installPhase = ''
    install -Dm755 bws $out/bin/bws
  '';

  meta = {
    description = "Bitwarden Secrets Manager CLI";
    homepage = "https://github.com/bitwarden/sdk-sm";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
