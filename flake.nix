{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    fenix,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        toolchain = fenix.packages.${system}.fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "sha256-s1RPtyvDGJaX/BisLT+ifVfuhDT1nZkZ1NcK8sbwELM=";
        };
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bacon
            just
            toolchain
          ];

          # Certain Rust tools won't work without this
          # This can also be fixed by using oxalica/rust-overlay and specifying the rust-src extension
          # See https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/3?u=samuela. for more details.
          RUST_SRC_PATH = "${fenix.packages.${system}.complete.rust-src}/lib/rustlib/src/rust/library";
        };
      }
    );
}
