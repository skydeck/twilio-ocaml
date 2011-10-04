type callback = string * [`Get | `Post]
    (** A Twilio callback: url * method *)

type fallback = callback * callback option
    (** A Twilio callback, with an optional fallback callback *)

type handler =
  [ `Application of string
  | `Callback of fallback
  ]
    (** Twilio handlers *)

type http_result =
  [ `Unserved
  | `Http_protocol_error of exn
  | `Redirection
  | `Client_error
  | `Server_error
  | `Timeout
  ]

type http_call_result = [ `Success of string | http_result ]
    (** Result of an API call *)

type 'a http_parsed_result =
  [ `Success of 'a
  | `Parse_error of exn * string
  | http_result
  ]
    (** Parsed result of an API call *)
