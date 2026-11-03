app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.26.0/GddgvsGjiNXrHFW6au5i5dUDbTs8FinQdrgE2Gqmw53t.tar.zst",
}

import cli.Cmd
import cli.Stdout

main! : List(Str) => Try({}, [Exit(I32), ..])
main! = |_args| {
    Stdout.line!("build-platform: cargo staticlib → platform/targets/")?
    Cmd.exec!("bash", ["scripts/build_platform.sh"])?
    Ok({})
}
