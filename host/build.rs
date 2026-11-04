use std::path::PathBuf;
use std::process::Command;

fn main() {
    let manifest_dir = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let root = manifest_dir.parent().expect("repo root").to_path_buf();
    let out_dir = root.join("target/roc");
    std::fs::create_dir_all(&out_dir).ok();

    let app_main = root.join("app/hello/main.roc");
    let out_lib = out_dir.join("libapp.a");

    println!("cargo:rerun-if-changed={}", root.join("platform").display());
    println!("cargo:rerun-if-changed={}", root.join("app").display());

    // host/.bin/roc-stable
    let roc = roc_bin(&manifest_dir);

    let status = Command::new(&roc)
        .arg("build")
        .arg(format!("--output={}", out_lib.display()))
        .arg("--target=x64glibc")
        .arg(app_main.to_str().unwrap())
        .current_dir(&root)
        .status()
        .unwrap_or_else(|e| {
            panic!(
                "roc-stable not runnable from build.rs ({e}). \
                 Launch jackdaw via Blueprint so roc-stable is on PATH."
            );
        });

    if !status.success() {
        panic!("roc build failed: {status}");
    }

    // Adjust if Roc names the archive differently
    let lib = if out_lib.is_file() {
        out_lib
    } else {
        // fallback: first .a in out_dir
        std::fs::read_dir(&out_dir)
            .ok()
            .into_iter()
            .flatten()
            .filter_map(|e| e.ok())
            .map(|e| e.path())
            .find(|p| p.extension().and_then(|x| x.to_str()) == Some("a"))
            .expect("no .a produced under target/roc")
    };

    let search = lib.parent().unwrap();
    let stem = lib.file_stem().unwrap().to_str().unwrap();
    let name = stem.strip_prefix("lib").unwrap_or(stem);

    println!("cargo:rustc-link-search=native={}", search.display());
    println!("cargo:rustc-link-lib=static={name}");
    println!("cargo:rustc-link-arg=-no-pie");
}

fn roc_bin(manifest_dir: &std::path::Path) -> std::path::PathBuf {
    let local = manifest_dir.join(".bin/roc-stable");
    if local.is_file() {
        return local;
    }
    if let Ok(p) = std::env::var("ROC") {
        let p = std::path::PathBuf::from(p);
        if p.is_file() {
            return p;
        }
    }
    "roc-stable".into()
}
