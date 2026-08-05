{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  dbus,
}:

rustPlatform.buildRustPackage {
  pname = "secretspec";
  version = "unstable-2026-07-17";

  src = fetchFromGitHub {
    owner = "cachix";
    repo = "secretspec";
    rev = "8fa325976d54990a0397ef1ede3670e7b42615f5";
    hash = "sha256-JLiVSh4LoylqOdm47j8mWqbUbOg6sBsctW+S0FMjpCc=";
  };

  cargoHash = "sha256-+8k3oATVBBBq1gS3Klj3tUoObXkDc4ucfdQ84Bqkr4c=";

  buildAndTestSubdir = "secretspec";
  buildFeatures = [ "infisical" ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    dbus
  ];

  meta = {
    description = "Declarative secrets management (with Infisical provider)";
    homepage = "https://github.com/cachix/secretspec";
  };
}
