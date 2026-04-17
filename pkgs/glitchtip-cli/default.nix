{
  lib,
  rustPlatform,
  fetchFromGitLab,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "glitchtip-cli";
  version = "0.1.0";

  src = fetchFromGitLab {
    owner = "glitchtip";
    repo = "glitchtip-cli";
    rev = "v${version}";
    hash = "sha256-SzICGUlgt1z3qySralVEEQXoGAJ5ZyL8M/RZmM3QCsM=";
  };

  cargoHash = "sha256-kY8iLxYQrBr4YbcaBvWfzk+WCxw6s9IHvHHJh37dT58=";

  nativeBuildInputs = [ pkg-config ];

  # Network-dependent tests (mockito) are not runnable in the Nix sandbox.
  doCheck = false;

  meta = {
    description = "Open source CLI for GlitchTip (Sentry-compatible error tracking)";
    homepage = "https://gitlab.com/glitchtip/glitchtip-cli";
    license = lib.licenses.mit;
    mainProgram = "glitchtip-cli";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
