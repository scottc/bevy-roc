//! host: gameplay shared between `cargo run` and the
//! editor's Play button.
//!
//! Scene content (entities, components, positions) lives in
//! `assets/*.bsn` files authored in the editor. Game behaviour
//! (systems, observers, resources) lives in [`GamePlugin`].
//!
//! # Try it
//!
//! 1. Open this project in jackdaw.
//! 2. Outliner: click `Add Entity` and pick `Cube`.
//! 3. Components panel: click `Add Component` and pick `SpinningCube`.
//!    Set `speed` to `1.5`.
//! 4. `File > Save`, then click Play. The cube spins.
//! 5. `cargo run` launches the same game without the editor.
//!
//! # Adding your own components
//!
//! Write a component anywhere in this library (any module, not
//! `main.rs`), deriving `Component, Reflect, Default` with
//! `#[reflect(Component, Default)]`, like `SpinningCube` below. After you
//! save, click Rebuild in jackdaw (or run `jd build`) and it
//! appears in `Add Component`. No registration code is needed.

//mod roc_ffi;

#[path = "glue_out/roc_platform_abi.rs"]
#[allow(dead_code, improper_ctypes, improper_ctypes_definitions, unexpected_cfgs)]
mod roc_platform_abi;
mod roc_host_runtime;

use bevy::prelude::*;
use jackdaw_runtime::prelude::*;
use roc_platform_abi::{roc_frame, roc_init, FrameOut, Model};

#[derive(Resource, Clone, Copy)]
pub struct RocModel(pub Model);

/// Your game's Bevy plugin. `main.rs` adds this for both `cargo run`
/// and the editor's Play button (same binary).
#[derive(Default)]
pub struct GamePlugin;

impl Plugin for GamePlugin {
    fn build(&self, app: &mut App) {
        app
            .insert_resource(ClearColor(Color::srgb(0.1, 0.1, 0.15)))
            .add_systems(Startup, (init_roc, spawn_scene).chain())
            .add_systems(Update, (
                //roc_frame_system,
                spin_cubes
            ));
    }
}

fn init_roc(mut commands: Commands) {
    eprintln!("[host] before roc_init");
    let model = unsafe { roc_init() };
    eprintln!("[host] after roc_init");
    commands.insert_resource(RocModel(model));
}

/// Load the authored scene; `JackdawPlugin` spawns its entities as
/// children of this root.
fn spawn_scene(mut commands: Commands, asset_server: Res<AssetServer>) {
    commands.spawn(JackdawSceneRoot(asset_server.load("scene.bsn")));
}

/// Call Roc each frame; drive Bevy clear color from FrameOut.
fn roc_frame_system(
    time: Res<Time>,
    mut model: ResMut<RocModel>,
    mut clear_color: ResMut<ClearColor>,
) {
    let dt = time.delta_secs();

    eprintln!("[host] before roc_frame");
    let FrameOut {
        model: next,
        clear_color: rgba,
    } = unsafe { roc_frame(model.0, dt) };
    eprintln!("[host] after roc_frame");

    model.0 = next;
    clear_color.0 = Color::srgba(rgba.r, rgba.g, rgba.b, rgba.a);
}

/// Spin-rate in radians per second. Attach it in the Components panel; the
/// editor sees this component with no registration code because Bevy's
/// `reflect_auto_register` picks up the `Reflect` derive. `Default` +
/// `#[reflect(Default)]` let the editor add it and the game reconstruct
/// it with sensible starting values.
#[derive(Component, Reflect, Default)]
#[reflect(Component, Default, @EditorCategory::new("Actor"))]
pub struct SpinningCube {
    pub speed: f32,
}

fn spin_cubes(time: Res<Time>, mut cubes: Query<(&SpinningCube, &mut Transform)>) {
    let dt = time.delta_secs();
    for (cube, mut transform) in &mut cubes {
        transform.rotate_y(cube.speed * dt);
    }
}
