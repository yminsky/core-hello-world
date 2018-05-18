open Core
open Async

let port =
  let open Command.Let_syntax in
  let%map_open port =
    flag "-port" (optional_with_default 8124 int) ~doc:" Broker's port"
  in
  port

let host_port_pair =
  let open Command.Let_syntax in
  [%map_open
    let port = port
    and host = flag "-hostname" (optional_with_default "127.0.0.1" string)
        ~doc:" Broker's hostname"
    in
    (host,port)
  ]

let with_rpc_conn f ~host ~port =
  Tcp.with_connection
    (Tcp.Where_to_connect.of_host_and_port
       (Host_and_port.create ~host ~port))
    ~timeout:(sec 1.)
    (fun _ r w ->
       match%bind Rpc.Connection.create r w ~connection_state:(fun _ -> ()) with
       | Error exn -> raise exn
       | Ok conn   -> f conn
    )

let start_server ~env ?(stop=Deferred.never ()) ~implementations ~port () =
  Log.Global.info "Starting server on %d" port;
  let implementations =
    Rpc.Implementations.create_exn ~implementations
      ~on_unknown_rpc:(`Call (fun _ ~rpc_tag ~version ->
          Log.Global.info "Unexpected RPC, tag %s, version %d" rpc_tag version;
          `Continue
        ))
  in
  let%bind server =
    Tcp.Server.create
      ~on_handler_error:(`Call (fun _ exn -> Log.Global.sexp [%sexp (exn : Exn.t)]))
      (Tcp.Where_to_listen.of_port port)
      (fun _addr r w ->
         Rpc.Connection.server_with_close r w
           ~connection_state:(fun _ -> env)
           ~on_handshake_error:(
             `Call (fun exn -> Log.Global.sexp [%sexp (exn : Exn.t)]; return ()))
           ~implementations
      )
  in
  Log.Global.info "Server started, waiting for close";
  Deferred.any
    [ (stop >>= fun () -> Tcp.Server.close server)
    ; Tcp.Server.close_finished server ]
