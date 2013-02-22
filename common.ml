open Core.Std
open Async.Std

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
