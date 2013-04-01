open Core.Std

(* Exercises:

   - Add a subcommand for writing new greeting files, with this interface:

     $ ./main.byte make-greeting -name Joe -greeting Yo greet-joe.sexp
*)

module Message : sig
  type t with sexp

  val to_string : t -> string
end = struct
  type greeting =
  | Hello
  | Goodbye
  with sexp

  type t =
    { name : string
    ; greeting : greeting
    } with sexp
      
  let to_string t =
    sprintf "%s, %s"
      (Sexp.to_string (sexp_of_greeting t.greeting))
      t.name
end

let greet_cmd =
  Command.basic
    ~summary:"Greet someone from a message file"
    Command.Spec.(
      empty
      +> anon ("message-file" %: file) 
    )
    (fun file () ->
      (* Read an s-expression from the given file, and uses
         [Messgae.t_of_sexp] to convert the s-expression to a
         [Message.t] *)
      let message = Sexp.load_sexp_conv_exn file Message.t_of_sexp in
      printf "%s\n%!" (Message.to_string message))

let command =
  Command.basic
    ~summary:"Greeting commands"
    [ "greet", greet_cmd
    ]

let () =
  (* Wrapping [Command.run] in [Exn.handle_uncaught] is necessary for
     better error messages from the sexplib when a [t_of_sexp]
     function fails. *)
  Exn.handle_uncaught ~exit:true (fun () -> Command.run command)
