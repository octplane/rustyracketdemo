extern crate libc;
extern crate chrono;

use std::ffi::CString;
use std::os::raw::c_char;
use std::ffi::CStr;
use std::slice;
use std::str;
use libc::size_t;
use chrono::*;

fn replace_(keys: Vec<&str>, values: Vec<&str>, target: String) -> String {
    let before: DateTime<UTC> = UTC::now();
    let mut rvalue = target;
    for (ix, k) in keys.iter().enumerate() {
        let v = values[ix];
        rvalue = rvalue.replace(k, v);
    }
    let after: DateTime<UTC> = UTC::now();
    println!("[RUST] Substitution took {}ms\n",
             (after - before).num_milliseconds());
    rvalue
}

#[no_mangle]
pub extern "C" fn replace(n: *const c_char, h: *const c_char, r: *const c_char) -> *const c_char {
    let before: DateTime<UTC> = UTC::now();
    let ret = unsafe {
        let needle = CStr::from_ptr(n).to_str().unwrap();
        let haystack = CStr::from_ptr(h).to_str().unwrap();
        let replacement = CStr::from_ptr(r).to_str().unwrap();
        let replaced: String = haystack.replace(needle, replacement);
        CString::new(replaced).unwrap().as_ptr()
    };

    let after: DateTime<UTC> = UTC::now();
    println!("Substitution took {}ms\n",
             (after - before).num_milliseconds());
    ret
}

#[no_mangle]
pub extern "C" fn replace_all(k: *const *const c_char,
                              v: *const *const c_char,
                              length: size_t,
                              target: *const c_char)
                              -> *const c_char {
    let before: DateTime<UTC> = UTC::now();
    let ks = unsafe { slice::from_raw_parts(k, length as usize) };
    let keys: Vec<&str> = ks.iter()
        .map(|&p| unsafe { CStr::from_ptr(p) })  // iterator of &CStr
        .map(|cs| cs.to_bytes())                 // iterator of &[u8]
        .map(|bs| str::from_utf8(bs).unwrap())   // iterator of &str
        .collect();
    let vs = unsafe { slice::from_raw_parts(v, length as usize) };
    let values: Vec<&str> = vs.iter()
        .map(|&p| unsafe { CStr::from_ptr(p) })  // iterator of &CStr
        .map(|cs| cs.to_bytes())                 // iterator of &[u8]
        .map(|bs| str::from_utf8(bs).unwrap())   // iterator of &str
        .collect();
    let ready: DateTime<UTC> = UTC::now();
    println!("[RUST ] Prepared data in {}ms\n",
             (ready - before).num_milliseconds());

    let haystack = unsafe { CStr::from_ptr(target).to_str().unwrap().into() };
    let rret = replace_(keys, values, haystack);
    CString::new(rret).unwrap().as_ptr()
}