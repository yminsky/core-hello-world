open Core.Std
open Async.Std
open Broker_protocol
module Ascii_table = Textutils.Std.Ascii_table

let shutdown =
  Common.with_rpc_conn (fun conn ->
    Rpc.Rpc.dispatch_exn shutdown_rpc conn ())

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
    let from =
      Option.value_exn (Sys.getenv "USER") ~message:"Unknown username"
      |> String.strip
      |> Username.of_string
    in
    Rpc.Rpc.dispatch_exn publish_rpc conn
      { Message.
        text; topic; from; time = Time.now () }
  )

let pub_cmd =
  Command.async_basic
    ~summary:"publish a single value"
    Command.Spec.(
      (host_and_port ())
      +> anon ("<topic>" %: Arg_type.create Topic.of_string)
      +> anon ("<text>" %: string)
    )
    (fun host port topic text () -> publish ~host ~port ~topic ~text)

let subscribe ~topic =
  Common.with_rpc_conn (fun conn ->
    let clear_string = "\027[H\027[2J" in
    Rpc.Pipe_rpc.dispatch subscribe_rpc conn topic
    >>= function
    | Error err -> Error.raise err
    | Ok (Error s) -> eprintf "subscribe failed: %s\n" s; return ()
    | Ok (Ok (pipe,_id)) ->
      Pipe.iter pipe ~f:(fun msg ->
        printf "%s%s\n%!" clear_string msg.Message.text;
        return ()
      ))

let sub_cmd =
  Command.async_basic
    ~summary:"subscribe to a topic"
    Command.Spec.(
      host_and_port ()
      +> anon ("<topic>" %: Arg_type.create Topic.of_string)
    )
    (fun host port topic () -> subscribe ~host ~port ~topic)

let sexp_print_dump dump =
  printf "%s\n"
    (Dump.sexp_of_t dump |> Sexp.to_string_hum)

let col = Ascii_table.Column.create
let columns =
  [ col "topic" (fun d -> Topic.to_string d.Dump.message.Message.topic)
  ; col "text"  (fun d -> d.Dump.message.Message.text) ~max_width:25
  ; col "#sub"  (fun d -> Int.to_string d.Dump.num_subscribers)
  ; col "time"  (fun d -> Time.to_sec_string d.Dump.message.Message.time)
  ]

let table_print_dump dump =
  printf "%s%!"
    (Ascii_table.to_string
       ~display:Ascii_table.Display.line
       ~limit_width_to:72
       columns dump)

let dump ~sexp =
  Common.with_rpc_conn (fun conn ->
    Rpc.Rpc.dispatch_exn dump_rpc conn ()
    >>= fun dump ->
    (if sexp then sexp_print_dump dump else table_print_dump dump);
    return ()
  )

let dump_cmd =
  Command.async_basic
    ~summary:"Get a full dump of the broker's state"
    Command.Spec.(
      host_and_port ()
      +> flag "-sexp" no_arg ~doc:" Show as raw s-expression"
    )
    (fun host port sexp () -> dump ~host ~port ~sexp)

let clear topic =
  Common.with_rpc_conn (fun conn ->
    Rpc.Rpc.dispatch_exn clear_rpc conn topic)

let clear_cmd =
  Command.async_basic
    ~summary:"Clear out a given topic"
    Command.Spec.(
      host_and_port ()
      +> anon ("<topic>" %: Arg_type.create Topic.of_string)
    )
    (fun host port topic () -> clear topic ~host ~port)

let () =
  Command.run
    (Command.group ~summary:"Utilities for interacting with message broker"
       [ "publish"  , pub_cmd
       ; "subscribe", sub_cmd
       ; "dump"     , dump_cmd
       ; "shutdown" , shutdown_cmd
       ; "clear"    , clear_cmd
       ])
