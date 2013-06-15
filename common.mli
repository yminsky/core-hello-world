open Async.Std

val port_arg : unit -> int    Command.Spec.param
val host_arg : unit -> string Command.Spec.param

val with_rpc_conn
  :  (Rpc.Connection.t -> 'a Deferred.t)
  -> host:string -> port:int
  -> 'a Deferred.t

val start_server
  :  env:'a
  -> ?stop : unit Deferred.t
  -> implementations:'a Rpc.Implementation.t list
  -> port:int
  -> unit
  -> unit Deferred.t
