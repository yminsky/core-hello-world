open! Core
open! Async

(* A command that sends the hello request  *)
let say_hello ~host ~port =
  Common.with_rpc_conn ~host ~port (fun conn ->
      let%map response = Rpc.Rpc.dispatch_exn Hello_protocol.hello_rpc conn "Hello" in
      printf "%s\n%!" response)

let command =
  Command.async
    ~summary:"Hello World client"
    Command.Let_syntax.(
      let%map_open (host,port) = Common.host_port_pair in
      fun () -> say_hello ~port ~host)


let () = Command.run command
