# Minimal Example: Packaging CMake project utilizing Corrosion in Nix

This project demonstrates how a [CMake](https://cmake.org/)-based project
utilizing a Rust library included via
[Corrosion](https://github.com/corrosion-rs/corrosion) can be packaged in
[Nix](https://nixos.org/).

## TL;DR

- `$ git checkout <repo>`
- `$ cd <repo>`
- `$ nix run .`

You will see the binary printing out some info it got from the library written
in Rust.

## About

This repository holds the sources for a standalone Rust crate using Cargo as
build system and also includes C++ sources for a binary built by CMake itself.
The binary utilizes functionality from the Rust library.
[Corrosion](https://github.com/corrosion-rs/corrosion) is used to import the
Cargo project into CMake.

On the Nix side, this repository exposes the CMake-project as
[Nix Flake](https://nixos.wiki/wiki/Flakes).

### Rust Library

The Rust library built here is called `sample_rust_cxx_bindings_lib` and is
located in `./rust_src`. Cargo build as classic library, i.e., not a library
in Rust library format. By using the tooling of the
[`cxx` project](https://cxx.rs/), Rust can generate C++ bindings to the library.

### Binary built with C++

The C++ binary built here is called `dummy_binary`. It is build with a typical
CMake-based setup. CMake uses [Corrosion](https://github.com/corrosion-rs/corrosion)
to import the crate and make its targets available in the CMake world.

Goal of this project is to explore and demonstrate how the minimal setup looks
and how the build system needs to be modified and look like in the end, so that
the whole project can be built in the natural way known from other Nix
derivations.

This means:
- decouple downloading of any resources from the build step
- pack the downloading of any resources into a dedicated Nix derivation
  which is the input derivation of the actual build step

### Corrosion

Corrosion solves two problems. It imports the targets from any `Cargo.toml`
file into the CMake-world and also makes generated files (header files etc.)
available for CMake-targets. Corrosion expects crates to use `cxx` to create
those bindings.

## Challenges

To build this CMake-based project in a [Nix derivation](https://nixos.org/), we
have to decouple downloading of external resources and the actual build step.
This specifically means that we must provide Corrosion itself as well as all
Cargo dependencies, so that no network access is required.

Specifically, we have to:

- Enable `$ cargo tree` to work
  - Corrosion uses this to find out the effective version of the `cxx`
    dependency
  - By default, it needs a registry, thus, talks with the network
- Provide `cxxbridge` in `$PATH`
  - Corrosion would run `$ cargo install cxxbridge-cmd@${cxx_VERSION}` which
    of course doesn't work in a derivation without network access.
- Provided vendored sources so that `$ cargo build` doesn't need network access
  when invoked by CMake.

## Design Goals

The design goal here is to not modify Corrosion itself and only require minor
modifications to the project itself. The normal CMake-build (not in a Nix
derivation) should not be blocked or hindered in any way.

## Solution

### Modifications to Build System

**TL;DR:** We modify the environment Cargo will see in a way that it just works
without network access.

- All `Cargo.lock` files must be checked in
  - Although it is not typical to check in `Cargo.lock` files for Rust
    libraries, this is crucial for build reproducibility.
- The crate `cxxbridge-cmd` must appear in `Cargo.lock`
  - This way, it can be vendored by Nix/Crane
  - It is sufficient to add it under `[build-dependencies]`
- Crates `cxxbridge-cmd` and `cxx` must appear in the exact same version in
  `Cargo.lock`
  - Corrosion expects `cxxbridge-cmd@${VERSION_OF_CXX}`

### Insights about the Nix Build

1. We build the Nix crate within the source (sub)tree using [Crane](https://crane.dev)
   as standalone project.
2. We build the `cxxbridge` binary of the `cxxbridge-cmd` crate from the sources
   that have been vendored in *step 1.*
3. We build the CMake-project just like typical CMake-projects in Rust, with
   the exception that the binary from *step 2.* is added as `nativeBuildInput`
   and that Cargo's environment will be altered in-place to use the vendored
   sources from *step 1.*

## Tested Toolchain Version

This project is focused on the following build tools and helpers:

- CMake in version `3.29.2`
- Corrosion in version `0.4.10`
- Crane in version `0.19.0`
- Nix in version `2.18.8`
- Rust/Cargo in version `1.81.0`
- Dependencies as referenced in `rust_src/Cargo.lock`

Other versions might work as well and the required steps are similar or even
equal.

## License

See [LICENSE file](./LICENSE).
