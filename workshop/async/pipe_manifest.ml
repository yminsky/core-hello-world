open Core.Std
open Async.Std

let file_size filename =
  Reader.file_contents filename >>| String.length

let manifest_size manifest_filename =
  let read_file manifest_file =
    let lines = Reader.lines manifest_file in
    Pipe.fold' lines ~init:0 ~f:(fun sum lineq ->
      Deferred.Queue.fold lineq ~init:sum ~f:(fun sum line ->
        file_size line
        >>= fun file_size ->
        return (sum + file_size)
      ))
  in
  Reader.with_file manifest_filename ~f:read_file
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
