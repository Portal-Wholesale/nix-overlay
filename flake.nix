{
  description = "Portal Wholesale shared Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      overlays.default = import ./overlay.nix;

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          inherit (pkgs)
            bws
            playwright-cli
            process-compose-mcp
            secretspec
            postgres-mcp
            meat
            ;
          # inherit (pkgs) secretspec-unstable;
          # Temporarily disabled; package definitions remain under ./pkgs.
          # inherit (pkgs) agent-browser glitchtip-cli xata-cli;
        }
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
          inherit (pkgs) rustdesk;
        }
      );

      checks = forAllSystems (system: self.packages.${system});
    };
}
