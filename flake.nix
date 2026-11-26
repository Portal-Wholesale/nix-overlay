{
  description = "Portal Wholesale shared Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
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
            beads
            bws
            cf
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

      checks = forAllSystems (
        system:
        self.packages.${system}
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          # Secret scan of the committed tree (no git history in the sandbox).
          gitleaks =
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            pkgs.runCommand "gitleaks" { nativeBuildInputs = [ pkgs.gitleaks ]; } ''
              export HOME="$TMPDIR" GOMAXPROCS="$NIX_BUILD_CORES"
              cd ${nixpkgs.lib.cleanSource ./.}
              gitleaks dir --no-banner --redact .
              touch $out
            '';
        }
      );
    };
}
