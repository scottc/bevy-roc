> [!IMPORTANT]
> In development, WIP. Only tested against x86_64 linux.

# Bevy-Roc

Roc language bindings for Bevy Game Engine.

## About

Lets you use use roc to write bevy game logic, while Bevy handles processing game entities & rendering. And Jackdaw handles scene editing & development tooling.

![Bevy-Roc Screenshot](brand/Screenshot_20261104_011826.png)

## Build & Run

```sh
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- run run-host
```

## Jackdaw Workflow

Jackdaw editor owns the build process, so we can have full intergration.

```sh
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- run jackdaw-open
```

```
Jackdaw Build / Play
        │
        ▼
cargo build -p host
        │
        ▼
host/build.rs  → roc build →  target/roc/libapp.a
        │
        ▼
rustc links Bevy host + libapp.a
        │
        ▼
Play runs that binary (IPC + maybe_windowless)
```
