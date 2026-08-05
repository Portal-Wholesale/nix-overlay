{
  lib,
  buildGoModule,
  fetchFromGitHub,
  gitMinimal,
  makeWrapper,
}:

buildGoModule {
  pname = "meat";
  version = "unstable-2026-08-03";

  src = fetchFromGitHub {
    owner = "boldsoftware";
    repo = "meat";
    rev = "f39f41dfe7b5b37a12b35fdfbaecc7e779855bd3";
    hash = "sha256-fj04sdMiwPxh4F+kBpF5c+YYeKnKCDD9dsIgwAGPoK4=";
  };

  vendorHash = null;

  subPackages = [ "cmd/meat" ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ gitMinimal ];

  # Build only the CLI, but exercise tests in both the CLI and library packages.
  preCheck = ''
    subPackages=
  '';

  postInstall = ''
    wrapProgram $out/bin/meat \
      --prefix PATH : ${lib.makeBinPath [ gitMinimal ]}
  '';

  meta = {
    description = "Abridge a code diff into a reading diff";
    homepage = "https://github.com/boldsoftware/meat";
    license = lib.licenses.asl20;
    mainProgram = "meat";
    platforms = lib.platforms.unix;
  };
}
