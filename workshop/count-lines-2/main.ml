open Core.Std

let rec build_counts counter =
  match In_channel.input_line stdin with
  | None -> counter (* EOF *)
  | Some line -> build_counts (Counter.touch counter line)

let count_lines () =
  let counter = build_counts Counter.empty in
  List.iter (Counter.top_n counter 10) ~f:(fun (line, count) ->
    printf "%3d: %s\n" count line)

let count_lines_cmd =
  Command.async_basic
    ~summary:"Count top 10 unique lines in a file"
    Command.Spec.(
      empty
    )
    count_lines

let command =
  Command.group
    ~summary:"A bunch of counting tools"
    [ "count-lines", count_lines_cmd
    ]

let () = Command.run command
