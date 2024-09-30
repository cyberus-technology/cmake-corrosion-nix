{
  # deps
  cmake,
  cargo,
  rustc,
  # cxxbridge-cmd at right version for corrosion
  cxxbridge-cmd,

  # helpers
  stdenv,
  nix-gitignore,
  corrosionSrc,
  rustLib,
}:

stdenv.mkDerivation {
  name = "dummy_binary";
  version = "0.0.0";
  src = nix-gitignore.gitignoreSource [ ] ../.;
  nativeBuildInputs = [
    cargo
    cmake
    cxxbridge-cmd
    rustc
  ];

  # Set env vars so that CMake knows the source location.
  CORROSION_SRC = corrosionSrc;

  # Prevent any online access.
  CARGO_NET_OFFLINE = "true";

  # Prepare the environment for Cargo so that no network access is required.
  preConfigure = ''
    mkdir -p rust_src/.cargo
    cat ${rustLib.cargoVendored}/config.toml >> rust_src/.cargo/config.toml
  '';
}
