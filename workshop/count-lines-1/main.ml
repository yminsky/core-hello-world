open Core.Std

let rec build_counts counts =
  match In_channel.input_line stdin with
  | None -> counts (* EOF *)
  | Some line ->
    let count =
      match List.Assoc.find counts line with
      | None -> 0
      | Some x -> x
    in
    build_counts (List.Assoc.add counts line (count + 1))

let count_lines () =
  let counts = build_counts [] in
  let sorted_counts = List.sort ~cmp:(fun (_, x) (_, y) -> Int.descending x y) counts in
  List.iter (List.take sorted_counts 10) ~f:(fun (line, count) ->
    printf "%3d: %s\n" count line)

let count_lines_cmd =
  Command.basic
    ~summary:"Count top 10 unique lines in a file"
    Command.Spec.(
      empty
    )
    count_lines
;;

let command =
  Command.group
    ~summary:"A bunch of counting tools"
    [ "count-lines", count_lines_cmd
    ]

let () = Command.run command
