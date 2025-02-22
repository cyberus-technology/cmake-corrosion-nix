{ craneLib, nix-gitignore }:

let
  commonArgs = {
    src = nix-gitignore.gitignoreSource [ ] ../rust_src;
  };

  # Downloaded and compiled dependencies.
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  cargoPackage = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });

  cargoVendored = craneLib.vendorCargoDeps commonArgs;
in
{
  inherit cargoPackage;
  inherit cargoVendored;
}
