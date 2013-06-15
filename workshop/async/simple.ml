open Core.Std
open Async.Std

let def =
  after (sec 0.5)
  >>= fun () ->
  printf "Hello ";
  after (sec 1.)
  >>= fun () ->
  printf "world!\n";
  shutdown 0;
  return ()

let () =
  never_returns (Scheduler.go ())
