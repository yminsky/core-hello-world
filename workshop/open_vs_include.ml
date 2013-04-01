module X = struct
  let n = 5
  let add1 x = x + 1
end

module Y : sig
  val add2 : int -> int
end = struct
  open X

  let add2 x = add1 (add1 x)
end

module Z : sig
  val add1 : int -> int
  val add2 : int -> int
end = struct
  include X

  let add2 x = add1 (add1 x)
end
