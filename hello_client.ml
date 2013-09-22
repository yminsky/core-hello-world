open Core.Std
open Async.Std

(* A command that sends the hello request  *)
let say_hello ~host ~port =
  Common.with_rpc_conn (fun conn ->
    Rpc.Rpc.dispatch_exn Hello_protocol.hello_rpc conn "Hello"
    >>| fun response ->
    printf "%s\n%!" response
  )
    ~host ~port

let command =
  Command.async_basic
    ~summary:"Hello World client"
    Command.Spec.(
      empty
      +> Common.port_arg ()
      +> Common.host_arg ()
    )
    (fun port host () -> say_hello ~port ~host)

let () = Command.run command
