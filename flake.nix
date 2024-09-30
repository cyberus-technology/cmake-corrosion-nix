{
  description = "Minimal Example: Packaging CMake project utilizing Corrosion in Nix";

  inputs = {
    crane.url = "github:ipetkov/crane/master";
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
              # TODO inputsFrom = [ self'.packages.default ];
              packages = with pkgs; [
                cargo
                cmake
                ninja
                rustc
                nixfmt-rfc-style
              ];
            };
          };
          formatter = pkgs.nixfmt-rfc-style;
          packages =
            let
              corrosionSrc = builtins.fetchTarball {
                url = "https://github.com/corrosion-rs/corrosion/archive/refs/tags/v0.4.tar.gz";
                sha256 = "sha256:1avfjaxgqx05fv2jqbqnk20rkyhhzq0r7kp9xyimqdvmgajarh3p";
              };

              #corrosionSrc = /home/pschuster/dev/corrosion;
              rustLib = pkgs.callPackage ./nix/build-rust.nix { craneLib = inputs.crane.mkLib pkgs; };
              cxxbridge-cmd = pkgs.callPackage ./nix/build-cxxbridge-cmd.nix { inherit rustLib; };

              cmakeProj = pkgs.callPackage ./nix/build-cmake-proj.nix {
                inherit corrosionSrc;
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
