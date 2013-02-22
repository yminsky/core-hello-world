open Async.Std

val with_rpc_conn
  :  (Rpc.Connection.t -> 'a Deferred.t)
  -> host:string -> port:int
  -> 'a Deferred.t
