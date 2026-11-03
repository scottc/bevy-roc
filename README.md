# Bevy-Roc

## About

## Open Jackdaw Scene Editor

Install Jackdaw, rustup, rust, roc & zig:
```sh
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- shell
```

New Jackdaw project:
```sh
jd new host
```

```sh
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- run rustup-default
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- run jackdaw-import

# edit host to add GamePlugin + JackdawPlugin as above
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- run jackdaw-doctor

# Building the rust host for the first time will take awhile...
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- run jackdaw-build

# Open the editor...
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- run jackdaw-open
```

## Build & Run
```
nix run github:lukewilliamboswell/roc-blueprint/0.11.0 -- run build-platform
```
