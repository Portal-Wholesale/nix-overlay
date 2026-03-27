{
  lib,
  rustPlatform,
  fetchFromGitHub,
  apple-sdk_15,
  stdenv,
}:

rustPlatform.buildRustPackage {
  pname = "agent-browser";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "747a3772e1f827307b8d5792fefe4b3b2b049f30";
    hash = "sha256-ZUcPPsLueMPEiCVXE9N4oBf5xwYvxQ71jfkbo9t/8xs=";
  };

  sourceRoot = "source/cli";

  cargoLock.lockFile = ./Cargo.lock;

  doCheck = false;

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_15
  ];

  meta = {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
  };
}
