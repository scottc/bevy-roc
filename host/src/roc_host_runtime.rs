//! Symbols Roc's compiled app expects from the host.
use std::alloc::{self, Layout};
use std::ffi::c_void;
use std::os::raw::c_char;

fn layout(size: usize, align: usize) -> Layout {
    let align = align.max(1).next_power_of_two();
    Layout::from_size_align(size.max(1), align).expect("invalid Roc alloc layout")
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn roc_alloc(size: usize, alignment: u32) -> *mut c_void {
    unsafe {
        let l = layout(size, alignment as usize);
        let p = alloc::alloc(l);
        if p.is_null() {
            std::alloc::handle_alloc_error(l);
        }
        p.cast()
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn roc_dealloc(ptr: *mut c_void, alignment: u32) {
    if ptr.is_null() {
        return;
    }
    // Roc often passes size via its own headers; many hosts use a conservative free.
    // Prefer the size Roc documents if your nightly's glue comments require it.
    // For pointer-only dealloc, store size next to allocations or use a matching API
    // from roc_platform_abi (RocHost). Minimal: if glue uses libc-style, use:
    let _ = alignment;
    // Without size, libc free is the usual stopgap:
    //libc::free(ptr);
    panic!("roc_dealloc not implemented in rust host.")
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn roc_realloc(
    ptr: *mut c_void,
    new_size: usize,
    old_size: usize,
    alignment: u32,
) -> *mut c_void {
    unsafe {
        if ptr.is_null() {
            return roc_alloc(new_size, alignment);
        }
        if new_size == 0 {
            roc_dealloc(ptr, alignment);
            return std::ptr::null_mut();
        }
        let align = (alignment as usize).max(1).next_power_of_two();

        let old = Layout::from_size_align_unchecked(old_size.max(1), align);
        let new = layout(new_size, align);
        let p = alloc::realloc(ptr.cast(), old, new.size());
        if p.is_null() {
            std::alloc::handle_alloc_error(new);
        }
        p.cast()
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn roc_crashed(msg: *const c_char) {
    let s = if msg.is_null() {
        "<null>".into()
    } else {
        unsafe { std::ffi::CStr::from_ptr(msg).to_string_lossy().into_owned() }
    };
    eprintln!("roc crashed: {s}");
    std::process::abort();
}
