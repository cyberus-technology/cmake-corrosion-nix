# Minimal Example: Packaging CMake project utilizing Corrosion in Nix

This is a CMake-based C++ project that builds a binary. This binary is linked
against a Rust library build from a regular Cargo project. This cargo project
builds a classic lib (not Rust lib format). By using the `cxx` crate, Rust can
generate bindings for C++.

On the CMake-side, we use [Corrosion](https://github.com/corrosion-rs/corrosion)
to import the crate and make its targets available in the CMake world.

Goal of this project is to explore and demonstrate how the minimal setup looks
like and how the build system can be modified, at best with only minor
adjustments, so that it can be built in a [Nix derivation](https://nixos.org/).

This means:
- decouple downloading of any resources from the build step
- pack the downloading of any resources into a dedicated Nix derivation
  which is the input derivation of the build step
