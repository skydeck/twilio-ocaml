(** Module to help make Lwt enabled Twilio_rest modules.
  *)

let set_event_system (pipeline : Http_client.pipeline) = pipeline#set_event_system

module Make(A : sig
  val account_sid : string
  val auth_token : string
  val timeout : float
end) = (struct
  let pipeline = ref None

  include Twilio_rest.Make(struct
    type 'a _r = 'a Lwt.t

    let (>>=) = Lwt.(>>=)
    let return = Lwt.return

    let account_sid = A.account_sid
    let auth_token  = A.auth_token

    let send http_call =
      match !pipeline with
        | None -> Lwt.fail (Failure "Forgot to call init in Twilio_rest_lwt")
        | Some pipeline ->
          let returned = ref false in
          let result =
            let thread, wakeup = Lwt.wait () in
            pipeline#add_with_callback http_call (fun http_call ->
              Lwt.wakeup wakeup http_call
            );
            thread >>= (fun call ->
              returned := true;
              return (Twilio_util.result_of_http_call call)
            )
          in
          let timeout_thread =
            Lwt_unix.sleep A.timeout >>= (fun () -> Lwt.return `Timeout)
          in
          Lwt.choose [result; timeout_thread]
  end)

  let init ?(debug=false) synchronization connections esys =
    let p = new Http_client.pipeline in
    Twilio_util.prep_pipeline A.account_sid A.auth_token p;
    pipeline := (Some p);
    p#set_options { p#get_options with
                     Http_client.synchronization = Http_client.Pipeline synchronization;
                     Http_client.number_of_parallel_connections = connections;
                  };

    if debug then
      p#set_options
        { p#get_options with
          Http_client.connection_timeout = 36000.0;
          verbose_status = true;
          verbose_request_header = true;
          verbose_request_contents = true;
          verbose_response_header = true;
          verbose_response_contents = true;
          verbose_connection = false;
        };
end)
