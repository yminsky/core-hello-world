open Async.Std

val with_rpc_conn
  :  (Rpc.Connection.t -> 'a Deferred.t)
  -> host:string -> port:int
  -> 'a Deferred.t

val port_arg : unit -> int    Command.Spec.param
val host_arg : unit -> string Command.Spec.param
