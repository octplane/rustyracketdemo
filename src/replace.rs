extern crate libc;

use std::ffi::CString;
use std::os::raw::c_char;


#[no_mangle]
pub extern "C" fn some_content() -> *const c_char {
    let rret = String::from("some content");
    CString::new(rret).unwrap().as_ptr()
}