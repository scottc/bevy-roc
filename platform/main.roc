platform ""
    requires {
        init! : {} => Model,
        frame! : Model, F32 => FrameOut,
    }
    exposes [Model, Rgba, FrameOut, Stdout]
    packages {}
    provides {
        "roc_init": init_for_host!,
        "roc_frame": frame_for_host!,
    }
    hosted {
        "roc_stdout_line": Host.roc_stdout_line!
    }
    targets: {
        inputs_dir: "targets/",
        x64glibc: { inputs: [app], output: Archive },
        # x64musl: { inputs: ["libhost.a", app] },
        # arm64musl: { inputs: ["libhost.a", app] },
        # x64mac: { inputs: ["libhost.a", app] },
        # arm64mac: { inputs: ["libhost.a", app] },
    }

import Host
import Stdout
import Model
import FrameOut
import Rgba

init_for_host! : () => Model
init_for_host! = || init!({})

frame_for_host! : Model, F32 => FrameOut
frame_for_host! = |model, dt| frame!(model, dt)
