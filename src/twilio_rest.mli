(** Module that binds twilio requests to sending an http_call, and then binds
  * the http_call to parsing the result.
  *)
module Make : functor (A : sig
  type 'a _r
    (** Abstract type for Lwt *)

  val ( >>= ) : 'a _r -> ('a -> 'b _r) -> 'b _r
    (** Bind operator for Lwt *)

  val return : 'a -> 'a _r
    (** Return a result *)

  val account_sid : string
    (** The Twilio account SID, needed for URLs.  The auth_token is added
        into the request by send (or outside the module) *)

  val send : Http_client.http_call -> Twilio_types.http_call_result _r
    (** Send the http_call, return the result *)
end) ->
sig
  (** See http://www.twilio.com/docs/api/rest/available-phone-numbers *)
  module Available_phone_numbers : sig
    module Local : sig
      val get :
        ?area_code:string ->
        ?contains:string ->
        ?in_region:string ->
        ?in_postal_code:string ->
        string ->
        Available_phone_numbers_local_j.response Twilio_types.http_parsed_result A._r
    end
    module Toll_free : sig
      val get : ?contains:string -> string -> Available_phone_numbers_tollfree_j.response Twilio_types.http_parsed_result A._r
    end
  end

  (** See http://www.twilio.com/docs/api/rest/outgoing-caller-ids *)
  module Outgoing_caller_ids : sig
    module Sid : sig
      val delete : string -> string Twilio_types.http_parsed_result A._r
      val get : string -> Outgoing_caller_ids_j.t Twilio_types.http_parsed_result A._r
      val post : string -> string ->  Outgoing_caller_ids_j.post_result Twilio_types.http_parsed_result A._r
    end
    val get :
      ?phone_number:string ->
      ?friendly_name:string ->
      unit ->
      Outgoing_caller_ids_j.page Twilio_types.http_parsed_result A._r
    val post :
      ?friendly_name:string ->
      ?call_delay:string ->
      ?extension:string ->
      string ->
      Outgoing_caller_ids_j.post_result Twilio_types.http_parsed_result A._r
  end

  (** See http://www.twilio.com/docs/api/rest/incoming-phone-numbers *)
  module Incoming_phone_numbers : sig
    module Sid : sig
      val delete : string -> string Twilio_types.http_parsed_result A._r
      val get : string -> Incoming_phone_numbers_j.t Twilio_types.http_parsed_result A._r
      val post :
        ?friendly_name:string ->
        ?api_version:[< `V2008_08_01 | `V2010_04_01 ] ->
        ?voice_handler:Twilio_types.handler ->
        ?status_callback:Twilio_types.callback ->
        ?voice_callerid_lookup:bool ->
        ?sms_handler:Twilio_types.handler ->
        ?account_sid:string ->
        string ->
        Incoming_phone_numbers_j.t Twilio_types.http_parsed_result A._r
    end
    val get :
      ?phone_number:string ->
      ?friendly_name:string ->
      unit ->
      Incoming_phone_numbers_j.page Twilio_types.http_parsed_result A._r
    val post :
      ?friendly_name:string ->
      ?voice_handler:Twilio_types.handler ->
      ?status_callback:Twilio_types.callback ->
      ?voice_callerid_lookup:bool ->
      ?sms_handler:Twilio_types.handler ->
      [< `AreaCode of string | `PhoneNumber of string ] ->
      Incoming_phone_numbers_j.t Twilio_types.http_parsed_result A._r
    module Local : sig
      val get :
        ?phone_number:string ->
        ?friendly_name:string ->
        unit ->
        Incoming_phone_numbers_j.page Twilio_types.http_parsed_result A._r
      val post :
        ?friendly_name:string ->
        ?voice_handler:Twilio_types.handler ->
        ?status_callback:Twilio_types.callback ->
        ?voice_callerid_lookup:bool ->
        ?sms_handler:Twilio_types.handler ->
        [< `AreaCode of string | `PhoneNumber of string ] ->
        Incoming_phone_numbers_j.t Twilio_types.http_parsed_result A._r
    end
    module Toll_free : sig
      val get :
        ?phone_number:string ->
        ?friendly_name:string ->
        unit ->
        Incoming_phone_numbers_j.page Twilio_types.http_parsed_result A._r
      val post :
        ?friendly_name:string ->
        ?voice_handler:Twilio_types.handler ->
        ?status_callback:Twilio_types.callback ->
        ?voice_callerid_lookup:bool ->
        ?sms_handler:Twilio_types.handler ->
        string ->
        Incoming_phone_numbers_j.t Twilio_types.http_parsed_result A._r
    end
  end

  (** See http://www.twilio.com/docs/api/rest/applications *)
  module Applications : sig
    module Sid : sig
      val delete : string -> string Twilio_types.http_parsed_result A._r
      val get : string -> Applications_j.t Twilio_types.http_parsed_result A._r
      val post :
        ?friendly_name:string ->
        ?api_version:[< `V2008_08_01 | `V2010_04_01 ] ->
        ?voice_callback:Twilio_types.fallback ->
        ?status_callback:Twilio_types.callback ->
        ?voice_callerid_lookup:bool ->
        ?sms_callback:Twilio_types.fallback ->
        string ->
        Applications_j.t Twilio_types.http_parsed_result A._r
    end
    val get : ?friendly_name:string -> unit -> Applications_j.page Twilio_types.http_parsed_result A._r
    val post :
      ?api_version:[< `V2008_08_01 | `V2010_04_01 ] ->
      ?voice_callback:Twilio_types.fallback ->
      ?status_callback:Twilio_types.callback ->
      ?voice_callerid_lookup:bool ->
      ?sms_callback:Twilio_types.fallback ->
      string ->
      Applications_j.t Twilio_types.http_parsed_result A._r
  end

  (** See http://www.twilio.com/docs/api/rest/connect-apps *)
  module Connect_apps : sig
    module Sid : sig
      val post :
        ?friendly_name:string ->
        ?authorized_redirect_url:string ->
        ?deauthorize_callback:Twilio_types.callback ->
        ?permissions:[< `Get_all | `Post_all ] list ->
        ?description:string ->
        ?company_name:string ->
        ?homepage_url:string ->
        string ->
        Connect_apps_j.t Twilio_types.http_parsed_result A._r
    end
    val get : unit -> Connect_apps_j.page Twilio_types.http_parsed_result A._r
  end

  (** See http://www.twilio.com/docs/api/rest/authorized-connect-apps *)
  module Authorized_connect_apps : sig
    module Sid : sig
      val get : string -> Authorized_connect_apps_j.t Twilio_types.http_parsed_result A._r
    end
    val get : unit -> Authorized_connect_apps_j.page Twilio_types.http_parsed_result A._r
  end

  (** See http://www.twilio.com/docs/api/rest/transcription *)
  module Transcriptions : sig
    module Sid : sig
      val get : [< `Json | `Txt ] -> string -> [> `Json of Transcriptions_j.t | `Txt of string ] Twilio_types.http_parsed_result A._r
    end
    val get : unit -> Transcriptions_j.page Twilio_types.http_parsed_result A._r
  end

  (** See http://www.twilio.com/docs/api/rest/recording *)
  module Recordings : sig
    module Sid : sig
      val get :
        [< `Mp3 | `Txt | `Wav | `Xml ] ->
        string ->
        [> `Mp3 of string
        | `Txt of string
        | `Wav of string
        | `Xml of string ] Twilio_types.http_parsed_result A._r
      val delete : string -> string Twilio_types.http_parsed_result A._r
    end
    val get :
      ?call_sid:string ->
      ?date_created:string ->
      unit ->
      Recordings_j.t Twilio_types.http_parsed_result A._r
    module Transcriptions : sig
      val get : string -> Transcriptions_j.t Twilio_types.http_parsed_result A._r
    end
  end

  (** See http://www.twilio.com/docs/api/rest/notification *)
  module Notifications : sig
    module Sid : sig
      val get : string -> Notifications_j.t Twilio_types.http_parsed_result A._r
      val delete : string -> string Twilio_types.http_parsed_result A._r
    end
    val get : ?log:string -> ?message_date:string -> unit -> Notifications_j.t Twilio_types.http_parsed_result A._r
  end

  (** See http://www.twilio.com/docs/api/rest/call *)
  module Calls : sig
    module Sid : sig
      val get : string -> Calls_j.t Twilio_types.http_parsed_result A._r
      val delete : string -> string Twilio_types.http_parsed_result A._r
      val post :
        ?twiml_url:string ->
        ?meth:string ->
        ?status:[< `Canceled | `Completed ] ->
        string ->
        Calls_j.t Twilio_types.http_parsed_result A._r
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
      ?start_time:string ->
      unit ->
      Calls_j.t Twilio_types.http_parsed_result A._r
    val post :
      ?status_callback:Twilio_types.callback ->
      ?send_digits:string ->
      ?if_machine:bool ->
      ?timeout:int ->
      handler:Twilio_types.handler ->
      from_number:string ->
      to_number:string ->
      unit ->
      Calls_j.t Twilio_types.http_parsed_result A._r
    module Recordings : sig
      val get : ?date_created:string -> string -> Recordings_j.t Twilio_types.http_parsed_result A._r
    end
    module Notifications : sig
      val get :
        ?log:string ->
        ?message_date:string ->
        string ->
        Notifications_j.t Twilio_types.http_parsed_result A._r
    end
  end

  (** See http://www.twilio.com/docs/api/rest/sms *)
  module Sms : sig
    module Messages : sig
      module Sid : sig
        val get : string -> Sms_messages_j.t Twilio_types.http_parsed_result A._r
      end
      val get :
        ?from_number:string ->
        ?to_number:string ->
        ?date_sent:string ->
        unit ->
        Sms_messages_j.page Twilio_types.http_parsed_result A._r
      val post :
        ?callback:[< `ApplicationSid of string
                  | `StatusCallback of string ] ->
        from_number:string ->
        to_number:string ->
        body:string ->
        unit ->
        Sms_messages_j.t Twilio_types.http_parsed_result A._r
    end
  end
end
