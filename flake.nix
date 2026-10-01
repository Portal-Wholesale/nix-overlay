{
  description = "Portal Wholesale shared Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
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
            crit
            fb-idb
            playwright-cli
            process-compose-mcp
            secretspec
            postgres-mcp
            pgbot
            meat
            portal-nixbot-setup
            ;
        }
        // nixpkgs.lib.optionalAttrs (nixpkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.beadbox) {
          inherit (pkgs) beadbox;
        }
        // nixpkgs.lib.optionalAttrs (nixpkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.codiff) {
          inherit (pkgs) codiff;
        }
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
          inherit (pkgs) rustdesk;
        }
        // nixpkgs.lib.optionalAttrs (nixpkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.idb-companion) {
          inherit (pkgs) idb-companion;
        }
      );

      checks = forAllSystems (system: self.packages.${system});
    };
}
