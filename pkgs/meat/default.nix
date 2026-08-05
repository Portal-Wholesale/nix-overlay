{
  lib,
  buildGoModule,
  fetchFromGitHub,
  gitMinimal,
  makeWrapper,
}:

buildGoModule {
  pname = "meat";
  version = "unstable-2026-08-04";

  src = fetchFromGitHub {
    owner = "boldsoftware";
    repo = "meat";
    rev = "4434a03ec0c440f3d939978e2fb1b65a530a4e5c";
    hash = "sha256-jMnGEhfnw8j8dYGnSiZveM72ZUu69+cKMTtUzE27KPM=";
  };

  vendorHash = null;

  subPackages = [ "cmd/meat" ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ gitMinimal ];

  # Build only the CLI, but exercise tests in both the CLI and library packages.
  preCheck = ''
    subPackages=
  '';

  # These upstream HTTP mock tests need loopback sockets, which are unavailable
  # in the Nix sandbox. Keep the remaining library and CLI tests enabled.
  checkFlags = [
    "-skip=^(TestAbridge_(AnthropicEditPlanEndToEnd|OpenAIEditPlanEndToEndPreservesReasoning)|TestGenerate_(RetriesTransient|NoRetryOnBadRequest|GivesUpAfterMaxAttempts|MaxTokensStopIsAnError|SendsMaxOutputTokens)|TestOpenAIGenerate_(StreamingText|IncompleteIsError)|TestDiscoverExeGatewayBase(|_NoLLMIntegration|_Team)|TestNewAnthropicFromEnv_(PrefersExplicitKey|FallsBackToGateway)|TestNewOpenAIFromEnv_PrefersExplicitKey|TestNewModelFromEnv_DefaultsToOpenAIThroughGateway)$"
  ];

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
