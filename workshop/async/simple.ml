open Core.Std
open Async.Std

let (_:unit Deferred.t) =
  after (sec 0.5)
  >>= fun () ->
  printf "Hello ";
  after (sec 1.)
  >>= fun () ->
  printf "world!\n";
  after (sec 2.)
  >>= fun () ->
  shutdown 0;
  return ()

let () =
  never_returns (Scheduler.go ())
