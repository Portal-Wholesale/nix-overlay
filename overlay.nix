final: prev: {
  bws = final.callPackage ./pkgs/bws { };
  playwright-cli = final.callPackage ./pkgs/playwright-cli { };
  process-compose-mcp = final.callPackage ./pkgs/process-compose-mcp { };
  agent-browser = final.callPackage ./pkgs/agent-browser { };
  secretspec = final.callPackage ./pkgs/secretspec { };
  glitchtip-cli = final.callPackage ./pkgs/glitchtip-cli { };
  postgres-mcp = final.callPackage ./pkgs/postgres-mcp { };
  rustdesk = final.callPackage ./pkgs/rustdesk { };
  xata-cli = final.callPackage ./pkgs/xata-cli { };
}
