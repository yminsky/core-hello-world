open Core.Std
open Async.Std
open Broker_protocol

(* First, we build the implementations *)

let publish_impl dir msg =
  return (Directory.publish dir msg)

let subscribe_impl dir topic ~aborted =
  return (
    match Directory.subscribe dir topic with
    | None -> Error "Unknown topic"
    | Some pipe ->
      don't_wait_for (aborted >>| fun () -> Pipe.close_read pipe);
      Ok pipe
  )

let dump_impl dir () =
  return (Directory.dump dir)

let shutdown_impl _dir () =
  (after (sec 0.1) >>> fun () -> shutdown 0);
  return ()

let implementations =
  [ Rpc.Rpc.     implement publish_rpc   publish_impl
  ; Rpc.Pipe_rpc.implement subscribe_rpc subscribe_impl
  ; Rpc.Rpc.     implement dump_rpc      dump_impl
  ; Rpc.Rpc.     implement shutdown_rpc  shutdown_impl
  ]

let command = Command.async_basic
  ~summary:"Start the message broker server"
  Command.Spec.(empty +> Common.port_arg ())
  (fun port () ->
    let directory = Directory.create () in
    Common.start_server ~port ~implementations ~env:directory)

let () =
  Exn.handle_uncaught ~exit:true (fun () -> Command.run command)

