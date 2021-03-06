open Core
open Async

(** The protocol for communicating between the hello client and server.
    There's a single RPC call exposed, which lets you send and receive a
    string.

    The [bin_query] and [bin_response] arguments are values that contain logic
    for binary serialization of the query and response types, in this case,
    both strings.

    The version number is used when you want to mint new versions of an RPC
    without disturbing older versions.
*)

let hello_rpc =
  Rpc.Rpc.create
    ~name:"hello-world"
    ~version:0
    ~bin_query:[%bin_type_class: string]
    ~bin_response:[%bin_type_class: string]
