{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  apple-sdk_15,
  stdenv,
}:

rustPlatform.buildRustPackage {
  pname = "process-compose-mcp";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "abderraouf-belalia";
    repo = "process-compose-mcp";
    rev = "f7267eed935b61d6acd7f3aece73ec8efbf846a0";
    hash = "sha256-vUZ/7Fdqs5zZn35loTtVT/OpJ8qfkJSpNwIWjYKd9/w=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  # Copy lockfile since repo doesn't have one committed
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_15
    ];

  meta = {
    description = "MCP server for process-compose orchestration";
    homepage = "https://github.com/abderraouf-belalia/process-compose-mcp";
    license = lib.licenses.mit;
  };
}
