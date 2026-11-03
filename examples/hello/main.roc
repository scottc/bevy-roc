app [init!, frame!] { pf: platform "../../platform/main.roc" }

import pf.Model exposing [Model]
# if Model/FrameOut/Rgba live only in the platform, import what you expose
# or redefine matching shapes here depending on your platform design

init! : _ => Model
init! = |_| { t: 0.0 }

frame! : Model, F32 => FrameOut
frame! = |model, dt|
    t = model.t + dt
    # slow pulse clear color driven by Roc
    s = (Num.sin t + 1.0) / 2.0
    {
        model: { t },
        clear_color: { r: s * 0.2, g: 0.1, b: 0.3, a: 1.0 },
    }
