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
              ];
            };
          };
          formatter = pkgs.nixfmt-rfc-style;
          packages.default = { /* TODO */ };
        };
    };
}
