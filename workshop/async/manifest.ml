open Core.Std
open Async.Std

let file_size filename =
  Reader.file_contents filename >>| String.length

let manifest_size manifest_filename =
  Reader.file_lines manifest_filename
  >>= fun manifest ->
  Deferred.all (List.map ~f:file_size manifest)
  >>= fun lengths ->
  return (List.fold ~f:(+) ~init:0 lengths)
;;

let run () =
  manifest_size "MANIFEST"
  >>= fun manifest_size ->
  printf "Total file size: %d\n" manifest_size;
  shutdown 0;
  return ()
;;

let () =
  don't_wait_for (run ());
  never_returns (Scheduler.go ());
