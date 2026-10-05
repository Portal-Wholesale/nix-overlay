{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  nodejs_22,
}:

buildNpmPackage rec {
  pname = "cf";
  version = "1.0.0-beta.12";

  # The npm tarball ships the prebuilt CLI; the GitHub source needs an
  # unpublished vendored toolchain to build.
  src = fetchurl {
    url = "https://registry.npmjs.org/cf/-/cf-${version}.tgz";
    hash = "sha256-LGaN+SuptzxQq1uElbwA71HzBk3en/cLPZwCyOTLMHY=";
  };

  nodejs = nodejs_22;

  # Upstream publishes no lockfile, and its devDependencies point at files
  # outside the tarball. package-lock.json is generated from the runtime
  # dependencies only:
  #   jq 'del(.devDependencies, .scripts)' package.json > package.json.new
  #   npm install --package-lock-only --ignore-scripts
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-wGIS0T7y77kS9WgrJZe+R0DkRUkx2H6S+PfR2PpijKg=";

  dontNpmBuild = true;

  # workerd's install script executes its prebuilt binary, which cannot run in
  # the Linux build sandbox. API commands do not use it.
  npmRebuildFlags = [ "--ignore-scripts" ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    HOME="$TMPDIR" $out/bin/cf --version | grep -F "${version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Cloudflare CLI for the whole Cloudflare API";
    homepage = "https://github.com/cloudflare/cf";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "cf";
  };
}
