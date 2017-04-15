open Core
open Async
open Broker_protocol

(* First, we build the implementations *)

let publish_impl (dir,_) msg =
  Log.Global.sexp ~level:`Debug [%sexp (msg : Message.t)];
  return (Directory.publish dir msg)

let subscribe_impl (dir,_) topic =
  return (
    match Directory.subscribe dir topic with
    | None -> Error "Unknown topic"
    | Some pipe -> Ok pipe
  )

let dump_impl (dir,_) () =
  return (Directory.dump dir)

let shutdown_impl (_,stop) () =
  Log.Global.info "Shutdown request";
  Ivar.fill_if_empty stop ();
  return ()

let clear_impl (dir,_) topic =
  Log.Global.info "Clearing topic %s" (Topic.to_string topic);
  Directory.clear_topic dir topic;
  return ()

(* We then create a list of all the implementations we're going to support in
   the server. *)

let implementations =
  [ Rpc.Rpc.     implement publish_rpc   publish_impl
  ; Rpc.Pipe_rpc.implement subscribe_rpc subscribe_impl
  ; Rpc.Rpc.     implement dump_rpc      dump_impl
  ; Rpc.Rpc.     implement shutdown_rpc  shutdown_impl
  ; Rpc.Rpc.     implement clear_rpc     clear_impl
  ]

(* Finally we create a command for starting the broker server *)

let command =
  Command.async
  ~summary:"Start the message broker server"
  Command.Spec.(
    empty
    +> Common.port_arg ()
    +> flag "-fg" no_arg ~doc:" Run in the foreground (daemonize is the default)"
  )
  (fun port fg () ->
    (* We use a blocking call to get the working directory, because the Async
       scheduler isn't running yet.
    *)
    let basedir = Core.Unix.getcwd () in
    let logfile = basedir ^/ "broker.log" in
    if not fg then
      Daemon.daemonize ()
        ~redirect_stdout:(`File_append logfile)
        ~redirect_stderr:(`File_append logfile)
        ~cd:basedir;
    Log.Global.set_output
      [ Log.Output.file `Text ~filename:logfile ];
    Log.Global.info "Starting up";
    let stop = Ivar.create () in
    let directory = Directory.create () in
    Common.start_server ()
      ~stop:(Ivar.read stop)
      ~port
      ~implementations
      ~env:(directory,stop)
    >>| fun () ->
    Log.Global.info "Shutting down"
  )

let () = Command.run command
