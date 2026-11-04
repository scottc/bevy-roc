import Host

Stdout := {}.{
    line! : Str => {}
    line! = Host.roc_stdout_line!
}
