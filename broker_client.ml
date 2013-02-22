open Core.Std
open Async.Std
open Protocol

let shell cmd args =
  In_thread.run (fun () ->
    try Ok (Core_extended.Shell.run_full cmd args)
    with exn -> Error exn)

let shutdown =
  Common.with_rpc_conn (fun conn ->
    Rpc.Rpc.dispatch shutdown_rpc conn ()
    >>= function
    | Ok  () -> return ()
    | Error err ->
      eprintf "failed!\n%s\n" (Error.to_string_hum err);
      return ()
  )

let host_and_port () =
  Command.Spec.(
    empty
    +> Common.host_arg ()
    +> Common.port_arg ()
  )

let shutdown_cmd =
  Command.async_basic (host_and_port ())
    ~summary:"Shut the broker down"
    (fun host port () -> shutdown ~host ~port)


let publish ~topic ~text =
  Common.with_rpc_conn (fun conn ->
    shell "whoami" []
    >>= fun username ->
    let username = Result.ok_exn username in
    let from = Username.of_string (String.strip username) in
    Rpc.Rpc.dispatch_exn publish_rpc conn
      { Message.
        text; topic; from; time = Time.now () }
  )

let pub_cmd = Command.async_basic
  ~summary:"publish a single value"
  Command.Spec.(
    (host_and_port ())
    +> anon ("<topic>" %: Arg_type.create Topic.of_string)
                          +> anon ("<text>" %: string)
  )
  (fun host port topic text () -> publish ~host ~port ~topic ~text)

let subscribe ~topic =
  Common.with_rpc_conn (fun conn ->
    shell "clear" []
    >>= fun clear_string ->
    let clear_string =
      (* if we're not on a terminal, just use the empty string *)
      match clear_string with
      | Ok s -> s | Error _ -> ""
    in
    Rpc.Pipe_rpc.dispatch subscribe_rpc conn topic
    >>= function
    | Error err -> Error.raise err
    | Ok (Error s) -> eprintf "subscribe failed: %s\n" s; return ()
    | Ok (Ok (pipe,_id)) ->
      Pipe.iter pipe ~f:(fun msg ->
        printf "%s%s\n%!" clear_string msg.Message.text;
        return ()
      ))

let sub_cmd = Command.async_basic
  ~summary:"subscribe to a topic"
  Command.Spec.(
    host_and_port ()
    +> anon ("<topic>" %: Arg_type.create Topic.of_string)
  )
  (fun host port topic () -> subscribe ~host ~port ~topic)


let dump =
  Common.with_rpc_conn (fun conn ->
    Rpc.Rpc.dispatch_exn dump_rpc conn ()
    >>= fun dump ->
    printf "%s\n"
      (Dump.sexp_of_t dump |! Sexp.to_string_hum);
    return ()
  )

let dump_cmd = Command.async_basic
  ~summary:"Get a full dump of the broker's state"
  (host_and_port ())
  (fun host port () -> dump ~host ~port)

let () =
  Exn.handle_uncaught ~exit:true (fun () ->
    Command.run
      (Command.group ~summary:"Utilities for interacting with message broker"
         [ "publish"  , pub_cmd
         ; "subscribe", sub_cmd
         ; "dump"     , dump_cmd
         ; "shutdown" , shutdown_cmd
         ]))

