open Async

val port : int Command.Param.t

val host_port_pair : (string * int) Command.Param.t

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
