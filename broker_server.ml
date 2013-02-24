open Core.Std
open Async.Std
open Broker_protocol

(* First, we build the implementations *)

let publish_impl (dir,_) msg =
  Log.Global.info "Message published";
  return (Directory.publish dir msg)

let subscribe_impl (dir,_) topic ~aborted =
  Log.Global.info "Subscription started";
  return (
    match Directory.subscribe dir topic with
    | None -> Error "Unknown topic"
    | Some pipe ->
      don't_wait_for (aborted >>| fun () -> Pipe.close_read pipe);
      Ok pipe
  )

let dump_impl (dir,_) () =
  Log.Global.info "Dump requested";
  return (Directory.dump dir)

let shutdown_impl (_,stop) () =
  Log.Global.info "Shutdown requested";
  Ivar.fill_if_empty stop ();
  return ()

(* We then create a list of all the implementations we're going to support in
   the server. *)

let implementations =
  [ Rpc.Rpc.     implement publish_rpc   publish_impl
  ; Rpc.Pipe_rpc.implement subscribe_rpc subscribe_impl
  ; Rpc.Rpc.     implement dump_rpc      dump_impl
  ; Rpc.Rpc.     implement shutdown_rpc  shutdown_impl
  ]

(* Finally we create a command for starting the broker server *)

let command = Command.async_basic
  ~summary:"Start the message broker server"
  Command.Spec.(
    empty
    +> Common.port_arg ()
  )
  (fun port () ->
    (* We use a blocking call to get the working directory, because the Async
       scheduler isn't running yet.
    *)
    let basedir = Core.Std.Unix.getcwd () in
(*
    let finish_daemonize =
      unstage
        (Daemon.daemonize_wait ()
           ~redirect_stdout:`Do_not_redirect
           ~redirect_stderr:`Do_not_redirect
           ~cd:basedir)
    in
*)
    Log.Global.set_output
      [ Log.Output.file `Text ~filename:(basedir ^/ "broker.log") ];
    return () >>= fun () ->
(*    finish_daemonize ();*)
    Log.Global.info "Starting broker";
    let stop = Ivar.create () in
    let directory = Directory.create () in
    Log.Global.info "Starting server";
    Common.start_server ()
      ~stop:(Ivar.read stop)
      ~port
      ~implementations
      ~env:(directory,stop)
  )

let () = Command.run command
