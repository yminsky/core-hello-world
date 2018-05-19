open Core
open Async

module Username : Identifiable = String
module Topic    : Identifiable = String

module Message = struct
  type t = { text: string
           ; topic: Topic.t
           ; from: Username.t
           ; time: Time.t
           }
  [@@deriving sexp, bin_io, compare]
end

module Dump = struct
  type single = { message : Message.t
                ; num_subscribers: int
                }
  [@@deriving sexp,bin_io, compare]
  type t = single list [@@deriving sexp, bin_io, compare]
end

let publish_rpc =
  Rpc.Rpc.create
    ~name:"publish"
    ~version:0
    ~bin_query:[%bin_type_class: Message.t]
    ~bin_response:[%bin_type_class: unit]

let subscribe_rpc =
  Rpc.Pipe_rpc.create ()
    ~name:"subscribe"
    ~version:0
    ~bin_query:[%bin_type_class: Topic.t]
    ~bin_response:[%bin_type_class: Message.t]
    ~bin_error:[%bin_type_class: string]

let dump_rpc =
  Rpc.Rpc.create
    ~name:"dump"
    ~version:0
    ~bin_query:[%bin_type_class: unit]
    ~bin_response:[%bin_type_class: Dump.t]

let shutdown_rpc =
  Rpc.Rpc.create
    ~name:"shutdown"
    ~version:0
    ~bin_query:[%bin_type_class: unit]
    ~bin_response:[%bin_type_class: unit]

let clear_rpc =
  Rpc.Rpc.create
    ~name:"clear"
    ~version:0
    ~bin_query:[%bin_type_class: Topic.t]
    ~bin_response:[%bin_type_class: unit]
