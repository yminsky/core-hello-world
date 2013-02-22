open Core.Std
open Async.Std

(** A simple RPC for saying hello *)
let hello_rpc = Rpc.Rpc.create
  ~name:"hello-world"
  ~version:0
  ~bin_query:String.bin_t
  ~bin_response:String.bin_t

