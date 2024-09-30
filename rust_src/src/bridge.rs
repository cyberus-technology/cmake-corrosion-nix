#[cxx::bridge]
pub mod ffi {
    #[namespace = "logging"]
    #[derive(Debug, PartialOrd)]
    enum SomeEnumFromRust {
        First = 0,
        Second = 1,
        Third = 2,
    }
}
