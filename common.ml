open Core.Std
open Async.Std

let port_arg () =
  Command.Spec.(
    flag "-port" (optional_with_default 8124 int)
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
    (fun _ r w ->
      Rpc.Connection.create r w ~connection_state:()
      >>= function
      | Error exn -> raise exn
      | Ok conn   -> f conn
    )

let start_server ~env ?(stop=Deferred.never ()) ~implementations ~port () =
  Log.Global.info "Starting server on %d" port;
  let implementations =
    Rpc.Implementations.create_exn ~implementations
      ~on_unknown_rpc:(`Call (fun ~rpc_tag ~version ->
        Log.Global.info "Unexpected RPC, tag %s, version %d" rpc_tag version))
  in
  Tcp.Server.create
    ~on_handler_error:(`Call (fun _ exn -> Log.Global.sexp exn Exn.sexp_of_t))
    (Tcp.on_port port)
    (fun _addr r w ->
      Rpc.Connection.server_with_close r w
        ~connection_state:env
        ~on_handshake_error:(
          `Call (fun exn -> Log.Global.sexp exn Exn.sexp_of_t; return ()))
        ~implementations
    )
  >>= fun server ->
  Log.Global.info "Server started, waiting for close";
  Deferred.any
    [ (stop >>= fun () -> Tcp.Server.close server)
    ; Tcp.Server.close_finished server ]
