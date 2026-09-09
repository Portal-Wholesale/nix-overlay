{
  lib,
  stdenvNoCC,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
  gitMinimal,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agent-native";
  version = "0.177.1";

  src = ./.;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-jt7JT0c20ldeK04mZnGX6rqp/XgYDjjpPbDX8y1svmA=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/agent-native $out/bin $out/share/licenses/agent-native
    cp -R node_modules package.json pnpm-lock.yaml $out/libexec/agent-native/
    cp LICENSE $out/share/licenses/agent-native/LICENSE

    substituteInPlace \
      $out/libexec/agent-native/node_modules/@agent-native/core/dist/cli/index.js \
      --replace-fail 'Sentry.init({' 'Sentry.init({ enabled: false,'
    find $out/libexec/agent-native/node_modules/@agent-native/{core,recap-cli}/dist \
      -type f -name '*.js' -exec sed -i \
      -e 's|npx @agent-native/core@latest|agent-native|g' \
      -e 's|npx @agent-native/recap-cli@latest|agent-native-recap|g' {} +

    makeWrapper ${lib.getExe nodejs} $out/bin/agent-native \
      --add-flags "$out/libexec/agent-native/node_modules/@agent-native/core/bin/agent-native.js" \
      --prefix PATH : ${
        lib.makeBinPath [
          gitMinimal
          pnpm_10
        ]
      } \
      --set DO_NOT_TRACK 1 \
      --set AGENT_NATIVE_TELEMETRY_DISABLED 1
    makeWrapper ${lib.getExe nodejs} $out/bin/agent-native-recap \
      --add-flags "$out/libexec/agent-native/node_modules/@agent-native/recap-cli/dist/cli.js" \
      --prefix PATH : ${
        lib.makeBinPath [
          gitMinimal
          pnpm_10
        ]
      } \
      --set DO_NOT_TRACK 1 \
      --set AGENT_NATIVE_TELEMETRY_DISABLED 1

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    gitMinimal
    nodejs
  ];
  installCheckPhase = ''
    $out/bin/agent-native --version | grep -F ${lib.escapeShellArg finalAttrs.version}
    grep -F '"version": "0.5.27"' \
      $out/libexec/agent-native/node_modules/@agent-native/recap-cli/package.json
    grep -F 'Sentry.init({ enabled: false,' \
      $out/libexec/agent-native/node_modules/@agent-native/core/dist/cli/index.js
    grep -F "export DO_NOT_TRACK='1'" $out/bin/agent-native
    grep -F "export AGENT_NATIVE_TELEMETRY_DISABLED='1'" $out/bin/agent-native
    grep -F "export DO_NOT_TRACK='1'" $out/bin/agent-native-recap
    grep -F "export AGENT_NATIVE_TELEMETRY_DISABLED='1'" \
      $out/bin/agent-native-recap
    $out/bin/agent-native-recap recap > recap-help.txt
    grep -F 'agent-native-recap recap collect-diff' recap-help.txt
    if grep -F 'npx @agent-native/recap-cli' recap-help.txt; then
      exit 1
    fi

    export HOME=$TMPDIR
    mkdir smoke-repo
    cd smoke-repo
    git init --quiet
    git config user.email nix-build@example.invalid
    git config user.name "Nix build"
    echo before > example.txt
    git add example.txt
    git commit --quiet -m before
    base=$(git rev-parse HEAD)
    echo after > example.txt
    git commit --quiet -am after
    head=$(git rev-parse HEAD)
    $out/bin/agent-native-recap recap collect-diff \
      --base "$base" --head "$head" --out recap.diff --stat recap.stat
    grep -F '+after' recap.diff

    $out/bin/agent-native plan local init \
      --title "Nix install check" --kind recap --dir local-recap
    $out/bin/agent-native plan local check --dir local-recap
  '';

  meta = {
    description = "Agent-Native framework and dependency-light visual recap CLI";
    homepage = "https://github.com/BuilderIO/agent-native";
    license = lib.licenses.mit;
    mainProgram = "agent-native";
    platforms = lib.platforms.unix;
  };

  passthru.recapVersion = "0.5.27";
})
