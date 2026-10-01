final: prev: {
  beadbox = final.callPackage ./pkgs/beadbox { };
  bws = final.callPackage ./pkgs/bws { };
  codiff = final.callPackage ./pkgs/codiff { };
  crit = final.callPackage ./pkgs/crit { };
  fb-idb = final.callPackage ./pkgs/fb-idb { };
  idb-companion = final.callPackage ./pkgs/idb-companion { };
  playwright-cli = final.callPackage ./pkgs/playwright-cli { };
  process-compose-mcp = final.callPackage ./pkgs/process-compose-mcp { };
  secretspec = final.callPackage ./pkgs/secretspec { };
  postgres-mcp = final.callPackage ./pkgs/postgres-mcp { };
  pgbot = final.callPackage ./pkgs/pgbot { };
  meat = final.callPackage ./pkgs/meat { };
  rustdesk = final.callPackage ./pkgs/rustdesk { };
  portal-nixbot-setup = final.callPackage ./pkgs/portal-nixbot-setup { };
}
