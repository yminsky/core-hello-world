open Core
open Async

(* The implementation of the "hello" RPC.  The first argument is the environment
   the query executes against, which in this case is trivial.

   The RPC waits a 10th of a second before responding just to show how you do a
   query whose implementation blocks.
*)
let hello_impl () hello =
  Log.Global.debug "received hello query (%s)" hello;
  let%bind () = Clock.after (sec 0.1) in
  return (hello ^ " World!")

(* The list of RPC implementations supported by this server *)
let implementations =
  [ Rpc.Rpc.implement Hello_protocol.hello_rpc hello_impl ]

(* The command-line interface.  We use [async_basic] so that the command starts
   the async scheduler, and exits when the server stops.  *)
let command =
  Command.async
    ~summary:"Hello World server"
    Command.Spec.(
      empty +> Common.port_arg ()
    )
    (fun port () -> Common.start_server ~env:() ~port ~implementations ())

let () = Command.run command
