// host/src/roc_stdout.rs
use std::ffi::CStr;
use std::os::raw::c_char;

/// Called from Roc. Jackdaw Play surfaces process stdout in the console.
#[no_mangle]
pub unsafe extern "C" fn roc_stdout_line(msg: *const c_char) {
    if msg.is_null() {
        return;
    }
    let s = CStr::from_ptr(msg).to_string_lossy();
    // Bevy log → same stream Jackdaw typically tails for the game
    bevy::log::info!(target: "roc", "{s}");
    // Belt-and-suspenders for PIE consoles that only capture stdout:
    println!("[roc] {s}");
}
