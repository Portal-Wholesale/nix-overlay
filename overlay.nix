final: prev: {
  bws = final.callPackage ./pkgs/bws { };
  process-compose-mcp = final.callPackage ./pkgs/process-compose-mcp { };
}
