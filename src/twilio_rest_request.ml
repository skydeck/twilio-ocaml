open Twilio_types

let (|>) x f = f x

let option_map f = function
  | Some x -> Some (f x)
  | None   -> None

let string_of_method = function
  | `Get  -> "GET"
  | `Post -> "POST"

let map_api_version = function
  | `V2010_04_01 -> "2010-04-01"
  | `V2008_08_01 -> "2008-08-01"

let add (name : string) (value : string option) lst =
  match value with
    | Some s -> (name, s) :: lst
    | None   -> lst

let with_optional_args url args =
  match
    List.fold_left
      (fun args (name, optional_value) -> add name optional_value args)
      []
      args
  with
    | []   -> url
    | args -> url ^ "?" ^ Netencoding.Url.mk_url_encoded_parameters args

let add_callback prefix (url,meth) lst =
  (prefix ^ "Url", url) :: (prefix ^ "Method", string_of_method meth) :: lst

let add_fallback prefix (callback, fallback) lst =
  let lst = add_callback prefix callback lst in
  match fallback with
    | Some cb -> add_callback (prefix ^ "Fallback") cb lst
    | None    -> lst

let add_handler prefix handler lst =
  match handler with
    | Some (`Application sid)   -> (prefix ^ "ApplicationSid", sid) :: lst
    | Some (`Callback fallback) -> add_fallback prefix fallback lst
    | None                      -> lst

let url_sid url sid = url ^ "/" ^ sid

module Make(A : sig
  type 'a _r
  val return : 'a -> 'a _r
  val account_sid : string
end) = struct
  let url = "https://api.twilio.com/2010-04-01/Accounts/" ^ A.account_sid

  let return_delete s    = A.return   s
  let return_get s       = A.return  (s ^ ".json")
  let return_post (sa : string * (string * string) list) =
    let (s,a) = sa in
    A.return ((s ^ ".json"), a)

  module Available_phone_numbers = struct
    let url = url ^ "/AvailablePhoneNumbers"

    module Local = struct
      let get ?area_code ?contains ?in_region ?in_postal_code iso_code =
        return_get
          (with_optional_args (url ^ "/" ^ iso_code ^ "/Local")
             ["AreaCode", area_code;
              "Contains", contains;
              "InRegion", in_region;
              "InPostalCode", in_postal_code
             ])
    end
    module Toll_free = struct
      let get ?contains iso_code =
        return_get
          (with_optional_args (url ^ "/" ^ iso_code ^ "/TollFree")
             ["Contains", contains;
             ])
    end
  end

  module Outgoing_caller_ids = struct
    let url = url ^ "/OutgoingCallerIds"

    module Sid = struct
      let delete sid = return_delete (url_sid url sid)
      let get sid = return_get (url_sid url sid)
      let post friendly_name sid = return_post ((url_sid url sid), ["FriendlyName", friendly_name])
    end

    let get ?phone_number ?friendly_name () =
      return_get
        (with_optional_args url
           ["PhoneNumber", phone_number;
            "FriendlyName", friendly_name;
           ])

    let post ?friendly_name ?call_delay ?extension phone_number =
      let args =
        ("PhoneNumber", phone_number) ::
          add "FriendlyName" friendly_name []
          |> add "CallDelay" call_delay
          |> add "Extension" extension
      in
      return_post (url, args)
  end

  module Incoming_phone_numbers = struct
    let url = url ^ "/IncomingPhoneNumbers"

    let post_args ?friendly_name ?api_version ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler ?account_sid () =
      add "FriendlyName" friendly_name []
      |> add "ApiVersion" (option_map map_api_version api_version)
      |> add_handler "Voice" voice_handler
      |> (fun lst -> match status_callback with
          | Some (url, m) -> ("StatusCallback", url) :: ("StatusCallbackMethod", string_of_method m) :: lst
          | None          -> lst)
      |> add "VoiceCallerIdLookup" (option_map string_of_bool voice_callerid_lookup)
      |> add_handler "Sms" sms_handler
      |> add "AccountSid" account_sid

    module Sid = struct
      let delete sid = return_delete (url_sid url sid)
      let get sid = return_get (url_sid url sid)
      let post ?friendly_name ?api_version ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler ?account_sid sid =
        return_post
          (url_sid url sid,
           post_args ?friendly_name ?api_version ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler ?account_sid ())
    end

    let get_common url ?phone_number ?friendly_name () =
      return_get
        (with_optional_args url
           ["PhoneNumber", phone_number;
            "FriendlyName", friendly_name;
           ])

    let number_arg = function
      | `PhoneNumber s -> "PhoneNumber", s
      | `AreaCode    s -> "AreaCode", s

    let get = get_common url
    let post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler number =
      let args =
        number_arg number
        :: post_args ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler ()
      in
      return_post (url, args)

    module Local = struct
      let url = url ^ "/Local"
      let get = get_common url
      let post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler number =
        let args =
          number_arg number
          :: post_args ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler ()
        in
        return_post (url, args)
    end

    module Toll_free = struct
      let url = url ^ "/TollFree"
      let get = get_common url
      let post ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler phone_number =
        let args =
          ("PhoneNumber", phone_number)
          :: post_args ?friendly_name ?voice_handler ?status_callback ?voice_callerid_lookup ?sms_handler ()
        in
        return_post (url, args)
    end
  end

  module Applications = struct
    let url = url ^ "/Applications"

    module Sid = struct
      let delete sid = return_delete (url_sid url sid)
      let get sid = return_get (url_sid url sid)
      let post ?friendly_name ?api_version ?voice_callback ?status_callback ?voice_callerid_lookup ?sms_callback sid =
        let voice_handler = option_map (fun cb -> `Callback cb) voice_callback in
        let sms_handler = option_map (fun cb -> `Callback cb) sms_callback in
        let args =
          Incoming_phone_numbers.post_args
            ?friendly_name
            ?api_version
            ?voice_handler
            ?status_callback
            ?voice_callerid_lookup
            ?sms_handler
            () in
        return_post ((url_sid url sid), args)
    end

    let get ?friendly_name () =
      return_get (with_optional_args url ["FriendlyName", friendly_name])

    let post ?api_version ?voice_callback ?status_callback ?voice_callerid_lookup ?sms_callback friendly_name =
      let voice_handler = option_map (fun cb -> `Callback cb) voice_callback in
      let sms_handler = option_map (fun cb -> `Callback cb) sms_callback in
      let args =
        Incoming_phone_numbers.post_args
          ~friendly_name
          ?api_version
          ?voice_handler
          ?status_callback
          ?voice_callerid_lookup
          ?sms_handler
          () in
      return_post (url, args)
  end

  module Connect_apps = struct
    let url = url ^ "/ConnectApps"

    let string_of_permissions permissions =
      String.concat ","
        (List.map
           (function
             | `Get_all  -> "get-all"
             | `Post_all -> "post-all"
           )
           permissions
        )

    module Sid = struct
      let get_sid = url_sid url
      let post ?friendly_name ?authorized_redirect_url ?deauthorize_callback ?permissions ?description ?company_name ?homepage_url sid =
        let args =
          add "FriendlyName" friendly_name []
          |> add "AuthorizedRedirectUrl" authorized_redirect_url
          |> (match deauthorize_callback with
              | Some cb -> add_callback "DeauthorizeCallback" cb
              | None    -> (fun x -> x))
          |> add "Permissions" (option_map string_of_permissions permissions)
          |> add "Description" description
          |> add "CompanyName" company_name
          |> add "HomepageUrl" homepage_url
        in
        return_post (url_sid url sid, args)
    end

    let get () = return_get url
  end

  module Authorized_connect_apps = struct
    let url = url ^ "/AuthorizedConnectApps"
    module Sid = struct
      let get sid = return_get (url_sid url sid)
    end
    let get () = return_get url
  end

  module Transcriptions = struct
    let url = url ^ "/Transcriptions"
    module Sid = struct
      let get format sid =
        let sid = sid ^ "." ^
          (match format with
            | `Json -> "json"
            | `Txt  -> "txt"
          )
        in
        A.return (url_sid url sid)
    end

    let get () = return_get url
  end

  module Recordings =
  struct
    let suffix = "/Recordings"

    module Sid = struct
      let get format sid =
        let sid = sid ^ "." ^
          (match format with
            | `Wav -> "wav"
            | `Mp3 -> "mp3"
            | `Txt -> "txt"
            | `Xml -> "xml"
          )
        in
        return_get (url_sid (url ^ suffix) sid)

      let delete sid = return_delete (url_sid url sid)
    end

    let list_common ?call_sid ?date_created url =
      with_optional_args url
        ["CallSid", call_sid;
         "DateCreated", date_created;
        ]

    let get ?call_sid ?date_created () =
      return_get (list_common ?call_sid ?date_created (url ^ suffix))

    module Transcriptions = struct
      let get sid = return_get (url ^ "/" ^ sid ^ "/Transcriptions")
    end
  end

  module Notifications = struct
    let url = url ^ "/Notifications"
    module Sid = struct
      let get sid = return_get (url_sid url sid)
      let delete sid = return_get (url_sid url sid)
    end

    let list_common ?log ?message_date url =
      with_optional_args url
        ["Log", log;
         "MessageDate", message_date;
        ]

    let get ?log ?message_date () = return_get (list_common ?log ?message_date url)
  end

  module Calls = struct
    let url = url ^ "/Calls"

    module Sid = struct
      let get sid = return_get (url_sid url sid)
      let delete sid = return_delete (url_sid url sid)

      let post ?twiml_url ?meth ?status sid =
        let status =
          option_map (function `Canceled -> "canceled" | `Completed -> "completed") status
        in
        let args =
          add "Url" twiml_url []
          |> add "Method" meth
          |> add "Status" status
        in
        return_post (url_sid url sid, args)
    end

    let get ?to_number ?from_number ?status ?start_time () =
      let status =
        option_map (function
          | `Ringing -> "ringing"
          | `In_progress -> "in-progress"
          | `Completed -> "completed"
          | `Failed -> "failed"
          | `Busy -> "busy"
          | `No_answer -> "no-answer"
        ) status
      in
      return_get
        (with_optional_args url
           ["To", to_number;
            "From", from_number;
            "Status", status;
            "StartTime", start_time;
           ])

    let post ?status_callback ?send_digits ?if_machine ?timeout ~handler ~from_number ~to_number () =
      let status_callback  =
        match status_callback with
          | Some (url, meth) ->
            ("StatusCallback", url) :: ["StatusCallbackMethod", (string_of_method meth)]
          | None -> []
      in
      let args =
        add_handler "" (Some handler) (["FromNumber", from_number; "ToNumber", to_number] @ status_callback)
        |> add "SendDigits" send_digits
        |> add "IfMachine" (option_map string_of_bool if_machine)
        |> add "Timeout" (option_map string_of_int timeout)
      in
      return_post (url, args)

    module Recordings = struct
      let get ?date_created sid =
        return_get
          (Recordings.list_common ?date_created
             (url ^ "/" ^ sid ^ "/Recordings"))
    end
    module Notifications = struct
      let get ?log ?message_date sid =
        return_get
          (Notifications.list_common ?log ?message_date
             (url_sid url sid ^ "/Notifications"))
    end
  end

  module Sms = struct
    let url = url ^ "/SMS"

    module Messages = struct
      let url = url ^ "/Messages"

      module Sid = struct
        let get sid = return_get (url_sid url sid)
      end

      let get ?from_number ?to_number ?date_sent () =
        return_get
          (with_optional_args url
             ["From", from_number;
              "To", to_number;
              "DateSent", date_sent;
             ])

      let post ?callback ~from_number ~to_number ~body () =
        let (args  : (string * string) list) =
          ["From", from_number;
           "To", to_number;
           "Body", body;
          ]
        in
        let (args : (string * string) list) =
          match callback with
            | Some (`StatusCallback url) -> ("StatusCallback", url) :: args
            | Some (`ApplicationSid sid) -> ("ApplicationSid", sid) :: args
            | None                       -> args
        in
        return_post (url, args)
    end
  end
end
