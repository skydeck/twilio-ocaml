(** Module to create requests for the Twilio API.  GET and DELETE requests
 *  return a url, while POST requests return a url plus arguments.
 *)
module Make : functor(A : sig
  type 'a _r
  val return : 'a -> 'a _r
  val account_sid : string
end) ->
sig
  (** See http://www.twilio.com/docs/api/rest/available-phone-numbers *)
  module Available_phone_numbers : sig
    module Local : sig
      val get :
        ?area_code:string ->
        ?contains:string ->
        ?in_region:string ->
        ?in_postal_code:string -> string -> string A._r
    end
    module Toll_free : sig
      val get : ?contains:string -> string -> string A._r
    end
  end

  (** See http://www.twilio.com/docs/api/rest/outgoing-caller-ids *)
  module Outgoing_caller_ids : sig
    module Sid : sig
      val delete : string -> string A._r
      val get : string -> string A._r
      val post : string -> string -> (string * (string * string) list) A._r
    end
    val get : ?phone_number:string -> ?friendly_name:string -> unit -> string A._r
    val post : ?friendly_name:string -> ?call_delay:string -> ?extension:string -> string -> (string * (string * string) list) A._r
  end

  (** See http://www.twilio.com/docs/api/rest/incoming-phone-numbers *)
  module Incoming_phone_numbers : sig
    val post_args :
      ?friendly_name:string ->
      ?api_version:[< `V2008_08_01 | `V2010_04_01 ] ->
      ?voice_handler:Twilio_types.handler ->
      ?status_callback:Twilio_types.callback ->
      ?voice_callerid_lookup:bool ->
      ?sms_handler:Twilio_types.handler ->
      ?account_sid:string -> unit -> (string * string) list
    module Sid : sig
      val delete : string -> string A._r
      val get : string -> string A._r
      val post :
        ?friendly_name:string ->
        ?api_version:[< `V2008_08_01 | `V2010_04_01 ] ->
        ?voice_handler:Twilio_types.handler ->
        ?status_callback:Twilio_types.callback ->
        ?voice_callerid_lookup:bool ->
        ?sms_handler:Twilio_types.handler ->
        ?account_sid:string ->
        string -> (string * (string * string) list) A._r
    end
    val get : ?phone_number:string -> ?friendly_name:string -> unit -> string A._r
    val post :
      ?friendly_name:string ->
      ?voice_handler:Twilio_types.handler ->
      ?status_callback:Twilio_types.callback ->
      ?voice_callerid_lookup:bool ->
      ?sms_handler:Twilio_types.handler ->
      [< `AreaCode of string | `PhoneNumber of string ] ->
      (string * (string * string) list) A._r
    module Local : sig
      val get : ?phone_number:string -> ?friendly_name:string -> unit -> string A._r
      val post :
        ?friendly_name:string ->
        ?voice_handler:Twilio_types.handler ->
        ?status_callback:Twilio_types.callback ->
        ?voice_callerid_lookup:bool ->
        ?sms_handler:Twilio_types.handler ->
        [< `AreaCode of string | `PhoneNumber of string ] ->
        (string * (string * string) list) A._r
    end
    module Toll_free : sig
      val get :
        ?phone_number:string ->
        ?friendly_name:string -> unit -> string A._r
              val post :
                ?friendly_name:string ->
                ?voice_handler:Twilio_types.handler ->
                ?status_callback:Twilio_types.callback ->
                ?voice_callerid_lookup:bool ->
                ?sms_handler:Twilio_types.handler ->
                string -> (string * (string * string) list) A._r
    end
  end

  (** See http://www.twilio.com/docs/api/rest/applications *)
  module Applications : sig
    module Sid : sig
      val delete : string -> string A._r
      val get : string -> string A._r
      val post :
        ?friendly_name:string ->
        ?api_version:[< `V2008_08_01 | `V2010_04_01 ] ->
        ?voice_callback:Twilio_types.fallback ->
        ?status_callback:Twilio_types.callback ->
        ?voice_callerid_lookup:bool ->
        ?sms_callback:Twilio_types.fallback ->
        string -> (string * (string * string) list) A._r
    end
    val get : ?friendly_name:string -> unit -> string A._r
    val post :
      ?api_version:[< `V2008_08_01 | `V2010_04_01 ] ->
      ?voice_callback:Twilio_types.fallback ->
      ?status_callback:Twilio_types.callback ->
      ?voice_callerid_lookup:bool ->
      ?sms_callback:Twilio_types.fallback ->
      string -> (string * (string * string) list) A._r
  end

  (** See http://www.twilio.com/docs/api/rest/connect-apps *)
  module Connect_apps : sig
    val string_of_permissions :
      [< `Get_all | `Post_all ] list -> string
    module Sid : sig
      val get_sid : string -> string
      val post :
        ?friendly_name:string ->
        ?authorized_redirect_url:string ->
        ?deauthorize_callback:Twilio_types.callback ->
        ?permissions:[< `Get_all | `Post_all ] list ->
        ?description:string ->
        ?company_name:string ->
        ?homepage_url:string ->
        string -> (string * (string * string) list) A._r
    end
    val get : unit -> string A._r
  end

  (** See http://www.twilio.com/docs/api/rest/authorized-connect-apps *)
  module Authorized_connect_apps : sig
    module Sid : sig
      val get : string -> string A._r
    end
    val get : unit -> string A._r
  end

  (** See http://www.twilio.com/docs/api/rest/transcription *)
  module Transcriptions : sig
    module Sid : sig
      val get : [< `Json | `Txt ] -> string -> string A._r
    end
    val get : unit -> string A._r
  end

  (** See http://www.twilio.com/docs/api/rest/recording *)
  module Recordings : sig
    module Sid : sig
      val get :
        [< `Mp3 | `Txt | `Wav | `Xml ] -> string -> string A._r
      val delete : string -> string A._r
    end
    val get : ?call_sid:string -> ?date_created:string -> unit -> string A._r
    module Transcriptions : sig
      val get : string -> string A._r
    end
  end

  (** See http://www.twilio.com/docs/api/rest/notification *)
  module Notifications : sig
    module Sid : sig
      val get : string -> string A._r
      val delete : string -> string A._r
    end
    val get :  ?log:string -> ?message_date:string -> unit -> string A._r
  end

  (** See http://www.twilio.com/docs/api/rest/call *)
  module Calls : sig
    module Sid : sig
      val get : string -> string A._r
      val delete : string -> string A._r
      val post :
        ?twiml_url:string ->
        ?meth:string ->
        ?status:[< `Canceled | `Completed ] ->
        string ->
        (string * (string * string) list) A._r
    end
    val get :
      ?to_number:string ->
      ?from_number:string ->
      ?status:[< `Busy
              | `Completed
              | `Failed
              | `In_progress
              | `No_answer
              | `Ringing ] ->
      ?start_time:string -> unit -> string A._r
    val post :
      ?status_callback:Twilio_types.callback ->
      ?send_digits:string ->
      ?if_machine:bool ->
      ?timeout:int ->
      handler:Twilio_types.handler ->
      from_number:string ->
      to_number:string ->
      unit -> (string * (string * string) list) A._r
    module Recordings : sig
      val get : ?date_created:string -> string -> string A._r
    end
    module Notifications : sig
      val get : ?log:string -> ?message_date:string -> string -> string A._r
    end
  end

  (** See http://www.twilio.com/docs/api/rest/sms *)
  module Sms : sig
    module Messages : sig
      module Sid : sig
        val get : string -> string A._r
      end
      val get :
        ?from_number:string ->
        ?to_number:string ->
        ?date_sent:string -> unit -> string A._r
      val post :
        ?callback:[< `ApplicationSid of string | `StatusCallback of string ] ->
        from_number:string ->
        to_number:string ->
        body:string -> unit -> (string * (string * string) list) A._r
    end
  end
end
