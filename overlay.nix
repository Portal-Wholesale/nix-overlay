final: prev: {
  bws = final.callPackage ./pkgs/bws { };
  playwright-cli = final.callPackage ./pkgs/playwright-cli { };
  process-compose-mcp = final.callPackage ./pkgs/process-compose-mcp { };
  agent-browser = final.callPackage ./pkgs/agent-browser { };
  secretspec = final.callPackage ./pkgs/secretspec { };
  glitchtip-cli = final.callPackage ./pkgs/glitchtip-cli { };
}
