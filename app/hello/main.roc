app [init!, frame!] { pf: platform "../../platform/main.roc" }

import pf.Model
import pf.FrameOut
import pf.Rgba

# Types come from the platform (adjust import if your platform exposes them differently)
# If Model / FrameOut / Rgba are only in the platform file, the app must use the same shapes.

init! : {} => Model
init! = |_| { t: 0.0 }

frame! : Model, F32 => FrameOut
frame! = |model, dt| {
    t = model.t + dt
    s = (t + 1.0) / 2.0
    {
        model: { t: t },
        clear_color: {
            r: s * 0.2,
            g: 0.1,
            b: 0.3,
            a: 1.0,
        },
    }
}
