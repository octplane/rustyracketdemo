use std::ffi::CString;
use std::os::raw::c_char;
use std::ffi::CStr;

#[no_mangle]
pub extern fn blur(n: *const c_char,
                   h: *const c_char,
                   r: *const c_char) -> *const c_char {
    unsafe {
        let needle = CStr::from_ptr(n).to_str().unwrap();
        let haystack = CStr::from_ptr(h).to_str().unwrap();
        let replacement = CStr::from_ptr(r).to_str().unwrap();
        let replaced: String = haystack.replace(needle, replacement);
        CString::new(replaced).unwrap().as_ptr()
    }



}
