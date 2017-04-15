open Core
open Async
open Broker_protocol

(* A publisher for a single topic *)
module Topic_pub : sig
  type t
  val create : Message.t -> t

  val publish                : t -> Message.t -> unit
  val subscribe              : t -> Message.t Pipe.Reader.t
  val num_subscribers        : t -> int
  val last_message           : t -> Message.t
  val close_subscriber_pipes : t -> unit
end = struct
  type t = { mutable last_message: Message.t;
             mutable subscribers: Message.t Pipe.Writer.t list;
           }

  let last_message t = t.last_message

  let create last_message =
    { last_message; subscribers = [] }

  let clear_closed t =
    t.subscribers <-
      List.filter t.subscribers ~f:(fun pipe ->
        not (Pipe.is_closed pipe))

  let close_subscriber_pipes t =
    List.iter t.subscribers ~f:Pipe.close;
    clear_closed t

  let publish t msg =
    clear_closed t;
    t.last_message <- msg;
    List.iter t.subscribers ~f:(fun pipe ->
      don't_wait_for (Pipe.write pipe msg))

  let subscribe t =
    let (r,w) = Pipe.create () in
    don't_wait_for (Pipe.write w t.last_message);
    t.subscribers <- w :: t.subscribers;
    r

  let num_subscribers t = List.length t.subscribers
end

type t = (Topic.t, Topic_pub.t) Hashtbl.t

let create () = Topic.Table.create ()

let clear_topic t topic =
  match Hashtbl.find t topic with
  | None -> ()
  | Some s -> 
    Topic_pub.close_subscriber_pipes s;
    Hashtbl.remove t topic

let publish t message =
  let s =
    Hashtbl.find_or_add t message.Message.topic
      ~default:(fun () -> Topic_pub.create message)
  in
  Topic_pub.publish s message

let subscribe t topic =
  Option.map (Hashtbl.find t topic) ~f:Topic_pub.subscribe

let dump t =
  Hashtbl.data t
  |> List.map ~f:(fun tpub ->
    let num_subscribers = Topic_pub.num_subscribers tpub in
    let message = Topic_pub.last_message tpub in
    {Dump. num_subscribers; message })

