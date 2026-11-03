platform ""
    requires {
        init! : {} => Model,
        frame! : Model, F32 => FrameOut,
    }
    exposes []
    packages {}
    provides {
        "roc_init": init_for_host!,
        "roc_frame": frame_for_host!,
    }
    hosted {}
    targets: {
        inputs_dir: "targets/",
        x64musl: { inputs: ["libhost.a", app] },
        arm64musl: { inputs: ["libhost.a", app] },
        x64mac: { inputs: ["libhost.a", app] },
        arm64mac: { inputs: ["libhost.a", app] },
    }

Model : { t : F32 }

Rgba : { r : F32, g : F32, b : F32, a : F32 }

FrameOut : {
    model : Model,
    clear_color : Rgba,
}

init_for_host! : () => Model
init_for_host! = || init!({})

frame_for_host! : Model, F32 => FrameOut
frame_for_host! = |model, dt| frame!(model, dt)
