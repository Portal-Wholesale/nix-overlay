final: prev: {
  bws = final.callPackage ./pkgs/bws { };
  playwright-cli = final.callPackage ./pkgs/playwright-cli { };
  process-compose-mcp = final.callPackage ./pkgs/process-compose-mcp { };
  secretspec = final.callPackage ./pkgs/secretspec { };
  postgres-mcp = final.callPackage ./pkgs/postgres-mcp { };
  meat = final.callPackage ./pkgs/meat { };
  rustdesk = final.callPackage ./pkgs/rustdesk { };

  # Temporarily disabled; uncomment these together with their flake exports.
  # agent-browser = final.callPackage ./pkgs/agent-browser { };
  # glitchtip-cli = final.callPackage ./pkgs/glitchtip-cli { };
  # xata-cli = final.callPackage ./pkgs/xata-cli { };
}
