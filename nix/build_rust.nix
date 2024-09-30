{
  craneLib,
  nix-gitignore,
}:

let
  commonArgs = {
    src = nix-gitignore.gitignoreSource [ ] ../rust_src;
  };

  # Downloaded and compiled dependencies.
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  cargoPackage = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });
in
{
  inherit cargoArtifacts;
  inherit cargoPackage;
}
