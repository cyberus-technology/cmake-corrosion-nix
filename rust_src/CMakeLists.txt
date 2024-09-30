include(FetchContent)

if (DEFINED ENV{CORROSION_SRC})
    message("Fetching corrosion source from env var: $ENV{CORROSION_SRC}")
    FetchContent_Declare(
            Corrosion
            SOURCE_DIR "$ENV{CORROSION_SRC}"
    )
else ()
    message("Fetching corrosion source from git")
    FetchContent_Declare(
            Corrosion
            GIT_REPOSITORY https://github.com/corrosion-rs/corrosion.git
            GIT_TAG stable/v0.4  # Newer versions require cmake 3.22 which is not available on Debian 11
    )
endif ()

FetchContent_MakeAvailable(Corrosion)

corrosion_import_crate(MANIFEST_PATH Cargo.toml)
if (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
    corrosion_set_env_vars(sample_rust_cxx_bindings_lib CXXFLAGS=-stdlib=libc++)
endif ()
corrosion_add_cxxbridge(cxx_rust_bridge CRATE sample_rust_cxx_bindings_lib FILES bridge.rs)
set_property(TARGET cxx_rust_bridge PROPERTY POSITION_INDEPENDENT_CODE TRUE)
