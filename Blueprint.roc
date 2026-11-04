app [config] {
    pf: platform "https://github.com/lukewilliamboswell/roc-blueprint/releases/download/0.11.0/EuSPs8vc71qJNFg29YzegvVRL1bR9pKqUYDHFiSCPTQ1.tar.zst",
}

import pf.Recipes

config = [
    Name("roc-bevy"),
    Systems(["x86_64-linux", "aarch64-linux", "aarch64-darwin"]),

    Packages("nix", From(NixPackages("github:NixOS/nixpkgs/nixos-unstable"))),
    Input("roc", "github:roc-lang/roc-overlay"),
    Input("rust", "github:oxalica/rust-overlay"),
    Input("jackdaw-nix", "path:./nix"),

    Environment(
        "dev",
        [
            Overlays(["roc", "rust", "jackdaw-nix"]),

            Programs([
                Fetch("roc-stable", Recipes.roc_nightly("nightly-2026-10-28-bad769b")),
            ]),

            Expect(["git"]),

            ToolWith(
                "nix#rust-bin.stable.latest.default",
                [
                    (
                        "targets",
                        List([
                            Str("x86_64-unknown-linux-gnu"),
                            Str("aarch64-unknown-linux-gnu"),
                            Str("x86_64-apple-darwin"),
                            Str("aarch64-apple-darwin"),
                        ]),
                    ),
                    ("extensions", List([Str("rust-src")])),
                ],
            ),

            Tools([
                "nix#pkg-config",
                "nix#wayland",
                "nix#libxkbcommon",
                "nix#libGL",
                "nix#libglvnd",
                "nix#mesa",
                "nix#vulkan-loader",
                "nix#vulkan-tools",
                "nix#alsa-lib",
                "nix#udev",
                "nix#libx11",
                "nix#libxcursor",
                "nix#libxi",
                "nix#libxrandr",
                "nix#gcc",
                "nix#rustup",
                "nix#jd",
                "nix#jackdaw",
                "nix#steam-run",
                "nix#zstd",
            ]),
        ],
    ),

    Shell("default", [Use("dev")]),

    Task("version", [Use("dev"), Run(["roc-stable", "version"])]),
    Task("rustc-version", [Use("dev"), Run(["rustc", "--version"])]),
    Task("cargo-version", [Use("dev"), Run(["cargo", "--version"])]),

    # Host crate lives under host/
    Task("gen-glue", [Use("dev"), Run(["bash", "scripts/gen_rust_glue.sh"])]),
    Task("cargo-check", [Use("dev"), Run(["cargo", "check", "-p", "host"])]),
    Task("build-host", [Use("dev"), Run(["cargo", "build", "-p", "host"])]),
    Task(
        "run-host",
        [
            Use("dev"),
            Run([
                "sh",
                "-c",
                "XKB=`pkg-config --variable=libdir xkbcommon 2>/dev/null`; WL=`pkg-config --variable=libdir wayland-client 2>/dev/null`; export LD_LIBRARY_PATH=\"/run/opengl-driver/lib:$XKB:$WL:$LD_LIBRARY_PATH\"; cargo run -p host",
            ]),
        ],
    ),

    # Platform + app under platform/ and app/
    Task("check-platform", [Use("dev"), Run(["roc-stable", "check", "platform/main.roc"])]),
    Task("check-app", [Use("dev"), Run(["roc-stable", "check", "app/hello/main.roc"])]),
    Task("build-platform", [Use("dev"), Run(["bash", "scripts/build_platform.sh"])]),

    # Rustup, just to tidy things up with the way jackdaw does things...
    # 2026-11-03T08:40:01.385376Z ERROR jackdaw::pie: PIE: game build of bevy-roc failed: error: rustup could not choose a version of cargo to run, because one wasn't specified explicitly, and no default is configured.
    Task("jackdaw-doctor", [Use("dev"), Run(["jd", "doctor", "--project", "host"])]),
    Task("jackdaw-setup", [Use("dev"), Run(["jd", "setup"])]),
    Task("rustup-default", [Use("dev"), Run(["rustup", "default", "1.99.0"])]),
    Task("jackdaw-import-preview", [Use("dev"), Run(["jd", "import", "host"])]),
    Task("jackdaw-import", [Use("dev"), Run(["jd", "import", "host", "--apply"])]),
    Task(
        "jackdaw-open",
        [
            Use("dev"),
            Run(["bash", "scripts/jackdaw_open.sh"]),
        ],
    ),
    Task("jackdaw-build", [Use("dev"), Run(["jd", "build", "--project", "host"])]),
    Task(
        "jackdaw-version",
        [
            Use("dev"),
            Run(["sh", "-c", "jd --help >/dev/null && jackdaw --help >/dev/null && echo jackdaw-ok"]),
        ],
    ),
]
