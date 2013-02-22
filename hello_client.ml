open Core.Std
open Async.Std

let say_hello port host =
  Common.with_rpc_conn ~port ~host (fun conn ->
    Rpc.Rpc.dispatch Hello_protocol.hello_rpc conn "Hello"
    >>= function
    | Ok response -> printf "%s\n%!" response; return ()
    | Error err ->
      eprintf "An error occurred:\n%s\n%!"
        (Error.to_string_hum err);
      return ()
  )

let command =
  Command.async_basic
    ~summary:"Hello World client"
    Command.Spec.(
      empty
      +> flag "-port" (optional_with_default 8012 int)
        ~doc:" server port"
      +> flag "-host" (optional_with_default "localhost" string)
        ~doc:" server host"
    )
    (fun port host () ->
      say_hello port host
    )

let () = Command.run command