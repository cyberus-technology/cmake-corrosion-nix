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

## Abstract Problem Description

Abstractly speaking, we have a project that builds an artifact. The build step
to produce this artifact downloads required resources from network within the
build step. This is challenging to package in Nix, where one typically splits
the downloading of artifacts and the actual build step.

## About

This repository holds the CMake-based project setup to build a binary. Further,
it holds the sources for a standalone Rust library crate using Cargo as build
system. The binary utilizes functionality exported from the Rust library.
[Corrosion](https://github.com/corrosion-rs/corrosion) is used to import the
Cargo project into CMake and linking it against the binary.

On the Nix side, this repository exposes the CMake-based project as
[Nix Flake](https://nixos.wiki/wiki/Flakes).

### Rust Library

The Rust library built here is called `sample_rust_cxx_bindings_lib` and is
located in `./rust_src`. Cargo build as classic library, i.e., not a library
in Rust library format. By using the tooling of the
[`cxx` project](https://cxx.rs/), Rust can generate C++ bindings to the library.

### C++ Binary

The C++ binary built here is called `dummy_binary`. It is build with a typical
CMake-based setup. CMake uses [Corrosion](https://github.com/corrosion-rs/corrosion)
to import the crate and make its targets available in the CMake world.

### Corrosion

Corrosion solves two problems. It imports the targets from any specified
`Cargo.toml` file into the CMake-world and also makes generated files (header
files etc.) available for CMake targets. Corrosion expects crates to use `cxx`
to create those bindings to them and to be built in traditional library format.

### Goal

The goal of this project is to explore and showcase what a minimal setup looks
like, and how the build system needs to be adjusted and structured so that the
entire project can be built seamlessly in Nix, following the typical approach
used in other Nix derivations.

This means:
- decouple downloading of any resources from the build step
- pack the downloading of any resources into a dedicated Nix derivation
  which is the input derivation of the actual build step

## Challenges

To build this CMake-based project in a [Nix derivation](https://nixos.org/), we
have to decouple downloading of external resources and the actual build step.
This specifically means that we must provide Corrosion itself as well as all
Cargo dependencies, so that no network access is required at any point of the
CMake project derivation.

Specifically, we have to:

- Enable `$ cargo tree` to work
  - Corrosion uses this command to find out the effective version of the `cxx`
    dependency
  - By default, the `cargo` invocation needs a registry, thus, talks with the
    network
- Provide `cxxbridge` in `$PATH`
  - Corrosion would run `$ cargo install cxxbridge-cmd@${cxx_VERSION}` if it
    is not already present, which of course doesn't work in a derivation without
    network access.
- Provide vendored sources so that `$ cargo build` doesn't need network access
  when invoked by CMake.

## Design Goals

The design goal here is to not modify Corrosion itself and only require minor
modifications to the build system. The normal CMake-build (not in a Nix
derivation) should not be blocked or hindered in any way.

## Solution

The solution presented here requires minor modifications to the build system,
and works with an unmodified version of Corrosion. The environment that Cargo
sees in the derivation of the CMake build is enriched with pre-fetched
dependencies from dedicated Nix derivations. Therefore, when Cargo is invoked by
CMake, Cargo doesn't need any network access.

### Why no Fixed-output Derivation?

As the artifact we build (the binary) contains Nix store paths, such as
libraries to dynamically link on program execution, fixed output derivations
won't work and will fail with
["Illegal path reference"](https://github.com/NixOS/nix/blob/7c506432abab84d79744f4454aa20fe0a458e0fb/src/libstore/build/local-derivation-goal.cc#L2573)
errors.

Fixed-output derivations are usually suited for downloading artifacts, and not
for building artifacts. **As a consequence, we have to decouple the downloading
of external resources from the build step!**

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
- Corrosion source must be passed in as pre-downloaded source (see
  `FetchContent_Declare` invocations)

### Insights about the Nix Build

1. We build the Nix crate within the source (sub)tree using [Crane](https://crane.dev)
   as standalone project.
2. We build the `cxxbridge` binary of the `cxxbridge-cmd` crate from the sources
   that have been vendored in *step 1.*
3. We build the CMake-project just like typical CMake-projects in Rust, with
   the exception that the binary from *step 2.* is added as `nativeBuildInput`
   and that Cargo's environment will be altered in-place to use the vendored
   sources from *step 1.*

## Tested Toolchain

This project is focused on the following build tools and helpers:

- Tools as specified by the used Nix shell. Specifically, this means:
  - CMake in version `3.29.2`
  - Rust/Cargo in version `1.81.0`
- Nix in version `2.18.8`
- Crane in version `0.19.0`
- Corrosion in version `0.4.10`
- Cargo Dependencies as referenced in `rust_src/Cargo.lock`
- Other flake dependencies as referenced in `flake.lock`

Other versions might work as well and the required steps are similar or even
equal.

## License

See [LICENSE file](./LICENSE).
