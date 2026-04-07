{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  dbus,
}:

rustPlatform.buildRustPackage {
  pname = "secretspec";
  version = "0-unstable-2026-04-07";

  src = fetchFromGitHub {
    owner = "cachix";
    repo = "secretspec";
    rev = "87d940f32c6b146299e4734847633d510cb268ae";
    hash = "sha256-53tDJEMEOszX51ecEmzGwTgaARSKm6KmaMUhKI3B7U4=";
  };

  cargoHash = "sha256-XqDWUQ9hzptNfGtTUftaokuuBsgMbE4HwiIZRQNp/C4=";

  buildAndTestSubdir = "secretspec";
  buildFeatures = [ "bws" ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    dbus
  ];

  meta = {
    description = "Declarative secrets management (with bws provider)";
    homepage = "https://github.com/cachix/secretspec";
  };
}
