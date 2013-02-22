open Core.Std
open Async.Std

(* The implementation of the "hello" RPC.  The first argument is the environment
   the query executes against, which in this case is trivial.

   The RPC waits a 10th of a second before responding just to show how you do a
   query whose implementation blocks.
*)
let hello_impl () hello =
  Clock.after (sec 0.1)
  >>= fun () -> return (hello ^ " World!")

(* The list of RPC implementations supported by this server  *)
let implementations =
  [ Rpc.Rpc.implement Hello_protocol.hello_rpc hello_impl ]

let command =
  Command.async_basic
    ~summary:"Hello World server"
    Command.Spec.(
      empty
      +> flag "-port" (optional_with_default 8012 int)
        ~doc:" server port"
    )
    (fun port () -> Common.start_server ~env:() ~port ~implementations)

let () = Command.run command
