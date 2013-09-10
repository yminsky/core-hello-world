open Core.Std
open Async.Std

module Username : Identifiable
module Topic : Identifiable

module Message : sig
  type t = { text: string;
             topic: Topic.t;
             from: Username.t;
             time: Time.t;
           }
  with sexp, bin_io, compare
end

module Dump : sig
  type single = { message : Message.t;
                  num_subscribers: int;
                }
  with sexp,bin_io, compare
  type t = single list with sexp,bin_io, compare
end


val publish_rpc   : (Message.t, unit)              Rpc.Rpc.t
val subscribe_rpc : (Topic.t, Message.t, String.t) Rpc.Pipe_rpc.t
val dump_rpc      : (unit, Dump.t)                 Rpc.Rpc.t
val shutdown_rpc  : (unit,unit)                    Rpc.Rpc.t
val clear_rpc     : (Topic.t, unit)                Rpc.Rpc.t
