open Core.Std

(* A very basic command-line program, using Command, Core's Command line
   parsing library.  *)

let command =
  (* [Command.basic] is used for creating a command.  Every command takes a text
     summary and a command line spec *)
  Command.basic
    ~summary:"Hello World"
    (* Command line specs are built up component by component, using a small
       combinator library whose operators are contained in [Command.Spec] *)
    Command.Spec.(
      empty
      +> flag "-hello" (optional_with_default "Hello" string)
        ~doc:" The 'hello' of 'hello world'"
      +> flag "-world" (optional_with_default "World" string)
        ~doc:" The 'world' of 'hello world'"
    )
    (* The command-line spec determines the argument to this function, which
       show up in an order that matches the spec. *)
    (fun hello world () -> printf "%s %s!\n" hello world)

let () = Command.run command
