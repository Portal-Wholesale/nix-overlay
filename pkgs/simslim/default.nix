{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "simslim";
  version = "0-unstable-2026-11-17";

  src = fetchFromGitHub {
    owner = "MobAI-App";
    repo = "simslim";
    rev = "f56a5a0e0ba04eb7315f7f1d624228ec68c80635";
    hash = "sha256-Cgm7hp3LBw635taWCQZypiDC1i8Qb4WVZL64g2jewwg=";
  };

  vendorHash = "sha256-y6Nbszl+bmjxRII6pryzv31mZN2BpSTuZYmrEVKxqu4=";

  subPackages = [ "cmd/simslim" ];

  ldflags = [ "-X main.version=f56a5a0" ];

  # Upstream tests shell out to xcrun simctl, which is unavailable in the
  # sandbox.
  doCheck = false;

  meta = {
    description = "Slim iOS simulators by disabling background launchd services";
    longDescription = ''
      Drives xcrun simctl, so it needs a selected Xcode developer directory
      at runtime.
    '';
    homepage = "https://github.com/MobAI-App/simslim";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "simslim";
  };
}
