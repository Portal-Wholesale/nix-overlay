# bd (Beads), shared by the CMS dev shells and clan's portal-board agents so
# both stay on one version against the shared portal_cms database. Keep the
# Dolt server pin in clan's services/dolt in step with Beads' tested Dolt.
{
  lib,
  buildGoModule,
  dolt,
  fetchFromGitHub,
  icu,
  installShellFiles,
  makeBinaryWrapper,
  stdenv,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "beads";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "gastownhall";
    repo = "beads";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nfPAhOrqmEMHHmkrLzxFHbldeUrRRyJiPYtwOVoC6ao=";
  };

  vendorHash = "sha256-nSOmq+SQ5d2rtS1XwetSN8i9rxlqlECgeofPKf0PjW0=";

  subPackages = [ "cmd/bd" ];

  ldflags = [
    "-s"
    "-w"
  ];

  buildInputs = [ icu ];

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  # Upstream's suite runs ~25 minutes of embedded-Dolt subprocess tests and
  # needs sandbox-specific skips; upstream CI already qualifies each release.
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/bd \
      --prefix PATH : ${lib.makeBinPath [ dolt ]}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd bd \
      --bash <($out/bin/bd completion bash) \
      --fish <($out/bin/bd completion fish) \
      --zsh <($out/bin/bd completion zsh)
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckProgramArg = "version";
  doInstallCheck = true;

  meta = {
    description = "Lightweight memory system for AI coding agents with graph-based issue tracking";
    homepage = "https://github.com/gastownhall/beads";
    license = lib.licenses.mit;
    mainProgram = "bd";
  };
})
