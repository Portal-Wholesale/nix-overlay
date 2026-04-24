{
  lib,
  python312,
  fetchFromGitHub,
}:

python312.pkgs.buildPythonApplication rec {
  pname = "postgres-mcp";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "crystaldba";
    repo = "postgres-mcp";
    rev = "v${version}";
    hash = "sha256-VCU7qVPbYyBBkLwtmNf+I0XxGzY4Qd7JFHEwbI8eU+I=";
  };

  # Upstream pins `pglast==7.11`; nixpkgs ships 7.13. pglast is a SQL parser
  # wrapper — minor version bumps are backwards-compatible in practice.
  pythonRelaxDeps = [ "pglast" ];

  build-system = with python312.pkgs; [ hatchling ];

  dependencies = with python312.pkgs; [
    mcp
    psycopg
    psycopg-pool
    humanize
    pglast
    attrs
    # nixpkgs' `instructor` package has several packaging issues we patch
    # around inline:
    #   - wheel declares `pre-commit` and `ty` as runtime deps (dev-only) → strip
    #   - `diskcache` is a real runtime dep but is missing from propagation → add
    #   - test suite is missing `jsonref` → skip tests
    # postgres-mcp's own pythonImportsCheck is our smoke validation.
    (instructor.overridePythonAttrs (old: {
      pythonRemoveDeps = (old.pythonRemoveDeps or [ ]) ++ [
        "pre-commit"
        "ty"
      ];
      dependencies = (old.dependencies or [ ]) ++ [ python312.pkgs.diskcache ];
      doCheck = false;
      doInstallCheck = false;
    }))
  ];

  # Integration tests require a live PostgreSQL + Docker, not runnable in
  # the Nix sandbox. The `pythonImportsCheck` below is our smoke test.
  doCheck = false;

  pythonImportsCheck = [ "postgres_mcp" ];

  meta = {
    description = "PostgreSQL tuning and analysis MCP server";
    homepage = "https://github.com/crystaldba/postgres-mcp";
    license = lib.licenses.mit;
    mainProgram = "postgres-mcp";
    platforms = lib.platforms.unix;
  };
}
