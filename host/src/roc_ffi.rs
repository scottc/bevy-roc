//! C ABI expected from the Roc platform provides:
//!   "roc_init"  -> init_for_host!
//!   "roc_frame" -> frame_for_host!
//!
//! Adjust #[repr(C)] layouts if `nm` / a crash shows a different Roc ABI.

#[repr(C)]
#[derive(Clone, Copy, Debug, Default)]
pub struct Model {
    pub t: f32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct Rgba {
    pub r: f32,
    pub g: f32,
    pub b: f32,
    pub a: f32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct FrameOut {
    pub model: Model,
    pub clear_color: Rgba,
}

unsafe extern "C" {
    /// platform provides { "roc_init": init_for_host! }
    pub fn roc_init() -> Model;

    /// platform provides { "roc_frame": frame_for_host! }
    pub fn roc_frame(model: Model, dt: f32) -> FrameOut;
}
