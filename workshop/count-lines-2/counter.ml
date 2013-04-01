open Core.Std

type t =
  (* equivalent to [(string * int) list] *)
  (string, int) List.Assoc.t 
with sexp

let empty = []

let touch t str =
  let count =
    match List.Assoc.find t str with
    | None -> 0
    | Some x -> x
  in
  List.Assoc.add t str (count + 1)

let top_n t n =
  let sorted_counts = List.sort ~cmp:(fun (_, x) (_, y) -> Int.descending x y) t in
  List.take sorted_counts n
