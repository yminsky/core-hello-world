open Core
open Async
open Broker_protocol
module Ascii_table = Textutils.Ascii_table

(* Shutdown command *****************************************)

let shutdown =
  Common.with_rpc_conn (fun conn ->
    Rpc.Rpc.dispatch_exn shutdown_rpc conn ())

let shutdown_cmd =
  Command.async ~summary:"Shut the broker down"
    Command.Let_syntax.(
      let%map_open (host,port) = Common.host_port_pair in
      fun () ->  shutdown ~host ~port)

(* Publish command ******************************************)

let publish ~topic ~text =
  Common.with_rpc_conn (fun conn ->
    let from =
      Option.value_exn (Sys.getenv "USER") ~message:"Unknown username"
      |> String.strip
      |> Username.of_string
    in
    Rpc.Rpc.dispatch_exn publish_rpc conn
      { text; topic; from; time = Time.now () }
  )

let pub_cmd =
  Command.async ~summary:"publish a single value"
    Command.Let_syntax.(
      [%map_open
        let (host,port) = Common.host_port_pair
        and topic = anon ("<topic>" %: Arg_type.create Topic.of_string)
        and text = anon ("<text>" %: string)
        in
        fun () ->
          publish ~host ~port ~topic ~text
      ])

(* Subscribe command ****************************************)

let subscribe ~topic =
  Common.with_rpc_conn (fun conn ->
    let clear_string = "\027[H\027[2J" in
    match%bind Rpc.Pipe_rpc.dispatch subscribe_rpc conn topic with
    | Error err -> Error.raise err
    | Ok (Error s) -> eprintf "subscribe failed: %s\n" s; return ()
    | Ok (Ok (pipe,_id)) ->
      Pipe.iter pipe ~f:(fun msg ->
        printf "%s%s\n%!" clear_string msg.Message.text;
        return ()
      ))

let sub_cmd =
  Command.async ~summary:"subscribe to a topic"
    Command.Let_syntax.(
      [%map_open
        let (host,port) = Common.host_port_pair
        and topic = anon ("<topic>" %: Arg_type.create Topic.of_string)
        in
        fun () -> subscribe ~host ~port ~topic
      ])

(* Dump command *********************************************)

let sexp_print_dump dump =
  printf "%s\n"
    (Dump.sexp_of_t dump |> Sexp.to_string_hum)

let col = Ascii_table.Column.create
let columns =
  [ col "topic" (fun d -> Topic.to_string d.Dump.message.Message.topic)
  ; col "text"  (fun d -> d.Dump.message.Message.text) ~max_width:25
  ; col "#sub"  (fun d -> Int.to_string d.Dump.num_subscribers)
  ; col "time"  (fun d ->
        Time.to_sec_string ~zone:(force Time.Zone.local) d.Dump.message.Message.time)
  ]

let table_print_dump dump =
  printf "%s%!"
    (Ascii_table.to_string
       ~display:Ascii_table.Display.line
       ~limit_width_to:72
       columns dump)

let dump ~sexp =
  Common.with_rpc_conn (fun conn ->
      let%bind dump = Rpc.Rpc.dispatch_exn dump_rpc conn () in
      (if sexp then sexp_print_dump dump else table_print_dump dump);
      return ()
  )

let dump_cmd =
  Command.async
    ~summary:"Get a full dump of the broker's state"
    Command.Let_syntax.(
      [%map_open
        let (host,port) = Common.host_port_pair
        and sexp =  flag "-sexp" no_arg ~doc:" Show as raw s-expression"
        in
        fun () -> dump ~host ~port ~sexp
      ])

(* Clear command ********************************************)

let clear topic =
  Common.with_rpc_conn (fun conn ->
    Rpc.Rpc.dispatch_exn clear_rpc conn topic)

let clear_cmd =
  Command.async ~summary:"Clear out a given topic"
    Command.Let_syntax.(
        let%map_open
          (host,port) = Common.host_port_pair
        and topic = anon ("<topic>" %: Arg_type.create Topic.of_string)
        in
        fun () -> clear topic ~host ~port)

(* Execution of final command *******************************)

let () =
  Command.run
    (Command.group ~summary:"Utilities for interacting with message broker"
       [ "publish"  , pub_cmd
       ; "subscribe", sub_cmd
       ; "dump"     , dump_cmd
       ; "shutdown" , shutdown_cmd
       ; "clear"    , clear_cmd
       ])
