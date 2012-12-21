open Core.Std

let command =
  Command.basic
    ~summary:"Hello World"
    Command.Spec.(
      empty
      +> flag "-hello" (optional_with_default "Hello" string)
        ~doc:" The 'hello' of 'hello world'"
      +> flag "-world" (optional_with_default "World" string)
        ~doc:" The 'world' of 'hello world'"
    )
    (fun hello world () ->
      printf "%s %s!\n" hello world
    )

let () =
  Command.run command
