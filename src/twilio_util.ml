let result_of_http_call call =
  match call#status with
    | `Successful             -> (`Success call#response_body#value)
    | `Unserved               -> `Unserved
    | `Http_protocol_error e  -> (`Http_protocol_error e)
    | `Redirection            -> `Redirection
    | `Client_error           -> `Client_error
    | `Server_error           -> `Server_error

let prep_pipeline account_sid auth_token pipeline =
  (* Prep for SSL *)
  Ssl.init ();
  let ctx = Ssl.create_context Ssl.TLSv1 Ssl.Client_context in
  let tct = (Https_client.https_transport_channel_type ctx :> Http_client.transport_channel_type) in
  pipeline#configure_transport Http_client.https_cb_id tct;

  (* Prep for authentication *)
  let key_handler =
    object
      method inquire_key ~domain ~realms ~auth =
        Http_client.key
          ~user:account_sid
          ~password:auth_token
          ~realm:(List.hd realms)
          ~domain
      method invalidate_key _key = ()
    end
  in
  let basic_auth_handler =
    new Http_client.basic_auth_handler
      ~enable_auth_in_advance:true
      key_handler
  in
  let digest_auth_handler =
    new Http_client.digest_auth_handler
      ~enable_auth_in_advance:true
      key_handler
  in
  pipeline#add_auth_handler basic_auth_handler;
  pipeline#add_auth_handler digest_auth_handler
