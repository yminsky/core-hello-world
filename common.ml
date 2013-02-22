open Core.Std
open Async.Std

let port_arg () =
  Command.Spec.(
    flag "-port" (optional_with_default 8080 int)
      ~doc:" Broker's port"
  )

let host_arg () =
  Command.Spec.(
    flag "-hostname" (optional_with_default "127.0.0.1" string)
      ~doc:" Broker's hostname"
  )

let with_rpc_conn f ~host ~port =
  Tcp.with_connection
    (Tcp.to_host_and_port host port)
    ~timeout:(sec 1.)
    (fun r w ->
      Rpc.Connection.create r w ~connection_state:()
      >>= function
      | Error exn -> raise exn
      | Ok conn -> f conn
    )

let start_server ~env ?(stop=Deferred.never ()) ~implementations ~port () =
  let implementations =
    Rpc.Implementations.create ~on_unknown_rpc:`Ignore ~implementations
  in
  match implementations with
  | Error (`Duplicate_implementations _) -> assert false
  | Ok implementations ->
    Tcp.Server.create
      ~on_handler_error:`Ignore
      (Tcp.on_port port)
      (fun _addr r w ->
        Rpc.Connection.server_with_close r w
          ~connection_state:env
          ~on_handshake_error:`Ignore
          ~implementations
      )
    >>= fun server ->
    Deferred.any
      [ (stop >>= fun () -> Tcp.Server.close server)
      ; Tcp.Server.close_finished server ]

