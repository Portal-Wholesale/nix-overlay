final: prev: {
  bws = final.callPackage ./pkgs/bws { };
  playwright-cli = final.callPackage ./pkgs/playwright-cli { };
  process-compose-mcp = final.callPackage ./pkgs/process-compose-mcp { };
  secretspec = final.callPackage ./pkgs/secretspec { };
  postgres-mcp = final.callPackage ./pkgs/postgres-mcp { };
  pgbot = final.callPackage ./pkgs/pgbot { };
  meat = final.callPackage ./pkgs/meat { };
  rustdesk = final.callPackage ./pkgs/rustdesk { };
}
