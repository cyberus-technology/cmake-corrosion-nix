{
  description = "Minimal Example: Packaging CMake project utilizing Corrosion in Nix";

  inputs = {
    crane.url = "github:ipetkov/crane/master";
    corrosion.url = "github:corrosion-rs/corrosion?ref=v0.4.10";
    corrosion.flake = false;
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = { };
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          system,
          self',
          pkgs,
          ...
        }:
        {
          devShells = {
            default = pkgs.mkShell {
              inputsFrom = [ self'.packages.default ];
              packages = with pkgs; [
                git
                ninja
                nixfmt-rfc-style
              ];
            };
          };
          formatter = pkgs.nixfmt-rfc-style;
          packages =
            let
              rustLib = import ./nix/build-rust.nix {
                inherit (pkgs) nix-gitignore;
                craneLib = inputs.crane.mkLib pkgs;
              };
              cxxbridge-cmd = pkgs.callPackage ./nix/build-cxxbridge-cmd.nix { inherit rustLib; };
              cmakeProj = pkgs.callPackage ./nix/build-cmake-proj.nix {
                corrosionSrc = inputs.corrosion;
                inherit rustLib;
                inherit cxxbridge-cmd;
              };
            in
            {
              inherit cmakeProj;
              default = cmakeProj;
              rustLib = rustLib.cargoPackage;
            };
        };
    };
}
