(** Convenience module for create Twilio_rest clients.
 *
 *  This module sets up the Http_client for syncrhonous
 *  requests.
 *)
module Make(A : sig
  val account_sid : string
  val auth_token : string
end) = (struct
  (** The [Http_client.pipeline] used for requests *)
  let pipeline =
    let p = new Http_client.pipeline in
    Twilio_util.prep_pipeline A.account_sid A.auth_token p;
    p

   (** Turn on/off debug features *)
  let set_debug f =
    Http_client.Debug.enable := f;
    pipeline#set_options
      { pipeline#get_options with
        Http_client.connection_timeout = 36000.0;
        verbose_status = f;
        verbose_request_header = f;
        verbose_request_contents = f;
        verbose_response_header = f;
        verbose_response_contents = f;
        verbose_connection = f;
      }

  include Twilio_rest.Make(struct
    type 'a _r = 'a

    let (>>=) a f = f a
    let return a = a
    let account_sid = A.account_sid
    let auth_token  = A.auth_token

    let send http_call =
      pipeline#add http_call;
      pipeline#run ();
      Twilio_util.result_of_http_call http_call
  end)
end)
