(** Module for printing out rest API requests *)
module Make(A : sig
  val account_sid : string
end) = (struct
  include Twilio_rest_request.Make(struct
    type 'a _r = 'a
    let return x = x
    let account_sid = A.account_sid
  end)
end)

(** For convenience, a fake module *)
include Make(struct
  let account_sid = "BogusSID"
end)
