{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "pgbot";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "pgrundev";
    repo = "pgbot";
    tag = "v${version}";
    hash = "sha256-rFqMXA9NRjbsSMZrn2vFXk3Kku/g3QyPPw3BjnveI7o=";
  };

  vendorHash = "sha256-A6BqprG7/Fi1Yi7jrVIlpxfyvfKmAyzUR2JEr+yoFTA=";

  # The release requires a newer Go 1.25 patch release than nixpkgs provides.
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.25.13" "go 1.25.0"
  '';

  subPackages = [ "cmd/pgbot" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/pgbot --version | grep -F ${lib.escapeShellArg version}
  '';

  meta = {
    description = "In-database observability for PostgreSQL";
    homepage = "https://pgbot.dev";
    changelog = "https://github.com/pgrundev/pgbot/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "pgbot";
    platforms = lib.platforms.unix;
  };
}
