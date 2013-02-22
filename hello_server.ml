open Core.Std
open Async.Std

let hello_impl () hello =
  Clock.after (sec 0.1)
  >>= fun () -> return (hello ^ " World!")

let implementations =
  [ Rpc.Rpc.implement Hello_protocol.hello_rpc hello_impl ]

let start_server ~port =
  let implementations =
    match Rpc.Implementations.create ~implementations ~on_unknown_rpc:`Ignore with
    | Ok x -> x
    | Error (`Duplicate_implementations _) -> assert false
  in
  Tcp.Server.create
    ~on_handler_error:`Ignore
    (Tcp.on_port port)
    (fun _addr r w ->
      Rpc.Connection.server_with_close r w
        ~connection_state:()
        ~on_handshake_error:`Ignore
        ~implementations
    )
  >>= fun server ->
  Tcp.Server.close_finished server

let command =
  Command.async_basic
    ~summary:"Hello World server"
    Command.Spec.(
      empty
      +> flag "-port" (optional_with_default 8012 int)
        ~doc:" server port"
    )
    (fun port () -> start_server ~port)

let () = Command.run command
