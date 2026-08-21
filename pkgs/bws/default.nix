{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  version = "2.1.0";
  system = stdenv.hostPlatform.system;
  selectAsset =
    {
      x86_64-linux = {
        url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v${version}/bws-x86_64-unknown-linux-musl-${version}.zip";
        hash = "sha256-9Z7hUOQrghKNQ3CH6brJIAU8a/3cuWDSDOk4blrJu6Y=";
      };
      aarch64-linux = {
        url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v${version}/bws-aarch64-unknown-linux-musl-${version}.zip";
        hash = "sha256-6w8a5h0cO3QkTShBIzJ24Fx36L5NoZftkPxiSDhwBeE=";
      };
      x86_64-darwin = {
        url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v${version}/bws-x86_64-apple-darwin-${version}.zip";
        hash = "sha256-b2JrOXE2iQKvG5hHwCeRobRmaWnXVh4gR2gc3teZdTc=";
      };
      aarch64-darwin = {
        url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v${version}/bws-aarch64-apple-darwin-${version}.zip";
        hash = "sha256-nLHBxuYWTYOy4zmIO6ArTLs3GIzppISxzoJJRDFj4GY=";
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
