cmake_minimum_required(VERSION 3.20)
project("cmake-corrosion-nix-packaging-minimal" LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(rust_src)

add_executable(dummy_binary src/main.cpp)
target_include_directories(dummy_binary PUBLIC cxx_rust_bridge)
target_link_libraries(dummy_binary PUBLIC cxx_rust_bridge)

install(TARGETS dummy_binary DESTINATION bin)
