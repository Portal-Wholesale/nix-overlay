final: prev: {
  bws = final.callPackage ./pkgs/bws { };
  playwright-cli = final.callPackage ./pkgs/playwright-cli { };
  process-compose-mcp = final.callPackage ./pkgs/process-compose-mcp { };
}
