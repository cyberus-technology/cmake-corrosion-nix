// These two come from the CMake "cxx_rust_bridge" target.
#include <cxx_rust_bridge/bridge.h>
#include <rust/cxx.h>

#include <iostream>
#include <format>

int main(int argc, const char* argv[])
{
    auto first = std::to_underlying(logging::SomeEnumFromRust::First);
    auto second = std::to_underlying(logging::SomeEnumFromRust::Second);
    std::cout << std::format("Hello World! first={}, second={}\n", first, second);
    return 0;
}
