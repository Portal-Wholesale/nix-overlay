{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "playwright-cli";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    tag = "v${version}";
    hash = "sha256-Ao3phIPinliFDK04u/V3ouuOfwMDVf/qBUpQPESziFQ=";
  };

  npmDepsHash = "sha256-4x3ozVrST6LtLoHl9KtmaOKrkYwCK84fwEREaoNaESc=";

  dontNpmBuild = true;

  meta = {
    description = "Playwright CLI for browser automation";
    homepage = "https://github.com/microsoft/playwright-cli";
    changelog = "https://github.com/microsoft/playwright-cli/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
  };
}
