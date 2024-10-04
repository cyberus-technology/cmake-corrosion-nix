# This derivation builds the "cxxbridge" command from the "cxxbridge-cmd" crate
# in the exact version specified by the "cxx" dependency of the Cargo.lock file.

{
  # deps
  cargo,
  gcc,
  # helpers
  lib,
  nix-gitignore,
  runCommand,
  rustLib,
}:

let
  src = rustLib.cargoPackage.src;
  lockFile = builtins.fromTOML (builtins.readFile "${src}/Cargo.lock");
  cxxVersion =
    let
      filtered = (lib.filter (e: e.name == "cxx") lockFile.package);
      package = builtins.head filtered;
    in
    package.version;
in
runCommand "cxxbridge-cmd-${cxxVersion}"
  {
    nativeBuildInputs = [
      cargo
      gcc
    ];
  }
  ''
    # Directory with vendored sources.
    DIR=$(cat ${rustLib.cargoVendored}/config.toml | grep -o '/nix/store/[^"]*' | cut -d'/' -f1-5)

    # Write the Cargo config to the proper location.
    mkdir -p .cargo
    cat ${rustLib.cargoVendored}/config.toml > .cargo/config.toml

    # Make sure our config.toml will be used by `cargo install`.
    export CARGO_HOME="$PWD/.cargo"

    export CARGO_TARGET_DIR="$PWD/target"

    mkdir -p $out/bin

    # Run `cargo install` on local source.
    cargo install \
      --verbose \
      --offline \
      --root $out \
      --path "$DIR/cxxbridge-cmd-${toString cxxVersion}"
  ''
