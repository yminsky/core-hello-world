open Core.Std
open Async.Std

let rec print_loop s =
  after (sec (Random.float 0.1))
  >>= fun () ->
  printf "[%s]" s;
  print_loop s

let () =
  don't_wait_for (print_loop "a");
  don't_wait_for (print_loop "b");
  never_returns (Scheduler.go ())
