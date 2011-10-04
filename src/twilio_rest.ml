let (|>) x f = f x

open Twilio_types

let identity x = x

module Make(A : sig
  type 'a _r
  val (>>=) : 'a _r -> ('a -> 'b _r) -> 'b _r
  val return : 'a -> 'a _r
  val account_sid : string
  val send : Http_client.http_call -> http_call_result _r
end) = struct
  module Request = Twilio_rest_request.Make(struct
    type 'a _r = 'a A._r
    let return = A.return
    let account_sid = A.account_sid
  end)

  let (>>=) = A.(>>=)

  let add_auth http_call =
    (* We add the authorization header ourselves instead of using netclient.
       The problem with netclient is that it (a) does not work with POST for
       Twilio's API and (b) requires two server connections (even when
       enable_auth_in_advance is true).
    *)
    http_call

  let send_delete url = failwith "TODO"
  let send_get url = new Http_client.get url |> add_auth |> A.send
  let send_post (url, args) = new Http_client.post url args |> add_auth |> A.send

  let return of_string s =
    A.return (match s with
      | `Success s -> (try `Success (of_string s) with e -> print_endline (Printexc.to_string e); print_endline (Printexc.get_backtrace ()); `Parse_error (e, s))
      | `Unserved  -> `Unserved
      | `Http_protocol_error e -> `Http_protocol_error e
      | `Redirection -> `Redirection
      | `Client_error -> `Client_error
      | `Server_error -> `Server_error
      | `Timeout -> `Timeout
    )

  module Available_phone_numbers = struct
    open Request.Available_phone_numbers

    module Local = struct
      let get ?area_code ?contains ?in_region ?in_postal_code iso_code =
        Local.get ?area_code ?contains ?in_region ?in_postal_code iso_code
          >>= send_get
          >>= return Available_phone_numbers_local_j.response_of_string
    end
    module Toll_free = struct
      let get ?contains iso_code =
        Toll_free.get ?contains iso_code
          >>= send_get
          >>= return Available_phone_numbers_tollfree_j.response_of_string
    end
  end

  module Outgoing_caller_ids = struct
    open Request.Outgoing_caller_ids
    open Outgoing_caller_ids_j

    module Sid = struct
      let delete sid = Sid.delete sid >>= send_delete >>= return identity
      let get sid = Sid.get sid >>= send_get >>= return t_of_string
      let post friendly_name sid = Sid.post friendly_name sid >>= send_post >>= return post_result_of_string
    end

    let get ?phone_number ?friendly_name () =
      get ?phone_number ?friendly_name () >>= send_get >>= return page_of_string

    let post ?friendly_name ?call_delay ?extension phone_number =
      post ?friendly_name ?call_delay ?extension phone_number
        >>= send_post
        >>= return post_result_of_string
  end

  module Incoming_phone_numbers = struct
    open Request.Incoming_phone_numbers
    open Incoming_phone_numbers_j
    module Sid = struct
      let delete sid = Sid.delete sid >>= send_delete >>= return identity
      let get sid = Sid.get sid >>= send_get >>= return t_of_string
      let post ?friendly_name ?api_version ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler ?account_sid sid =
        Sid.post ?friendly_name ?api_version ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler ?account_sid sid
          >>= send_post
          >>= return t_of_string
    end

    let get ?phone_number ?friendly_name () =
      get ?phone_number ?friendly_name () >>= send_get >>= return page_of_string

    let post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler number =
      post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler number
        >>= send_post
        >>= return t_of_string

    module Local = struct
      let get ?phone_number ?friendly_name () =
        Local.get ?phone_number ?friendly_name () >>= send_get >>= return page_of_string

      let post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler number =
        Local.post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler number
          >>= send_post
          >>= return t_of_string
    end

    module Toll_free = struct
      let get ?phone_number ?friendly_name () =
        Toll_free.get ?phone_number ?friendly_name () >>= send_get >>= return page_of_string

      let post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler number =
        Toll_free.post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler number
          >>= send_post
          >>= return t_of_string
    end
  end

  module Applications = struct
    open Request.Applications
    open Applications_j

    module Sid = struct
      let delete sid = Sid.delete sid >>= send_delete >>= return identity
      let get sid = Sid.get sid >>= send_get >>= return t_of_string
      let post ?friendly_name ?api_version ?voice_callback ?status_callback ?voice_callerid_lookup ?sms_callback sid =
        Sid.post ?friendly_name ?api_version ?voice_callback ?status_callback ?voice_callerid_lookup ?sms_callback sid
          >>= send_post
          >>= return t_of_string
    end

    let get ?friendly_name () = get ?friendly_name () >>= send_get >>= return page_of_string

    let post ?api_version ?voice_callback ?status_callback ?voice_callerid_lookup ?sms_callback friendly_name =
      post ?api_version ?voice_callback ?status_callback ?voice_callerid_lookup ?sms_callback friendly_name
        >>= send_post
        >>= return t_of_string
  end

  module Connect_apps = struct
    open Request.Connect_apps
    open Connect_apps_j

    module Sid = struct
      let post ?friendly_name ?authorized_redirect_url ?deauthorize_callback ?permissions ?description ?company_name ?homepage_url sid =
        Sid.post ?friendly_name ?authorized_redirect_url ?deauthorize_callback ?permissions ?description ?company_name ?homepage_url sid
          >>= send_post
          >>= return t_of_string
    end

    let get () = get () >>= send_get >>= return page_of_string
  end

  module Authorized_connect_apps = struct
    open Request.Authorized_connect_apps
    open Authorized_connect_apps_j

    module Sid = struct
      let get sid = Sid.get sid >>= send_get >>= return t_of_string
    end
    let get () = get () >>= send_get >>= return page_of_string
  end

  module Transcriptions = struct
    open Request.Transcriptions
    open Transcriptions_j
    module Sid = struct
      let get format sid =
        let of_string s =
          match format with
            | `Json -> `Json (t_of_string s)
            | `Txt  -> `Txt s
        in
        Sid.get format sid >>= send_get >>= return of_string
    end

    let get () = get () >>= send_get >>= return page_of_string
  end

  module Recordings =
  struct
    open Request.Recordings
    open Recordings_j

    module Sid = struct
      let get format sid =
        let of_string s =
          match format with
            | `Wav  -> `Wav s
            | `Mp3  -> `Mp3 s
            | `Txt  -> `Txt s
            | `Xml  -> `Xml s
        in
        Sid.get format sid >>= send_get >>= return of_string

      let delete sid = Sid.delete sid >>= send_delete >>= return identity
    end

    let get ?call_sid ?date_created () =
      get ?call_sid ?date_created () >>= send_get >>= return t_of_string

    module Transcriptions = struct
      open Transcriptions_j

      let get sid = Transcriptions.get sid >>= send_get >>= return t_of_string
    end
  end

  module Notifications = struct
    open Request.Notifications
    open Notifications_j

    module Sid = struct
      let get sid = Sid.get sid >>= send_get >>= return t_of_string
      let delete sid = Sid.delete sid >>= send_delete >>= return identity
    end

    let get ?log ?message_date () =
      get ?log ?message_date () >>= send_get >>= return t_of_string
  end

  module Calls = struct
    open Request.Calls
    open Calls_j

    module Sid = struct
      let get sid = Sid.get sid >>= send_get >>= return t_of_string
      let delete sid = Sid.delete sid >>= send_delete >>= return identity
      let post ?twiml_url ?meth ?status sid =
        Sid.post ?twiml_url ?meth ?status sid
          >>= send_post
          >>= return t_of_string
    end

    let get ?to_number ?from_number ?status ?start_time () =
      get ?to_number ?from_number ?status ?start_time ()
        >>= send_get
        >>= return t_of_string

    let post ?status_callback ?send_digits ?if_machine ?timeout ~handler ~from_number ~to_number () =
      post ?status_callback ?send_digits ?if_machine ?timeout ~handler ~from_number ~to_number ()
        >>= send_post
        >>= return t_of_string

    module Recordings = struct
      open Recordings_j

      let get ?date_created sid =
        Recordings.get ?date_created sid >>= send_get >>= return t_of_string
    end

    module Notifications = struct
      open Notifications_j
      let get ?log ?message_date sid =
        Notifications.get ?log ?message_date sid >>= send_get >>= return t_of_string
    end
  end

  module Sms = struct
    module Messages = struct
      open Request.Sms.Messages
      open Sms_messages_j

      module Sid = struct
        let get sid = Sid.get sid >>= send_get >>= return t_of_string
      end

      let get ?from_number ?to_number ?date_sent () =
        get ?from_number ?to_number ?date_sent ()
          >>= send_get
          >>= return page_of_string

      let post ?callback ~from_number ~to_number ~body () =
        post ?callback ~from_number ~to_number ~body ()
          >>= send_post
          >>= return t_of_string
    end
  end
end
