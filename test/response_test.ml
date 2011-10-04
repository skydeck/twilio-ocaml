let assert_equal ~printer ~msg ~expected actual =
  if expected = actual then
    ()
  else
    raise (Failure (Printf.sprintf "%s expected [%s] but got [%s]"
                      msg
                      (printer expected)
                      (printer actual)
                   )
          )

let assert_string ~msg ~expected actual = assert_equal (fun s -> s) msg expected actual
let assert_int  ~msg ~expected actual = assert_equal string_of_int msg expected actual
let assert_bool ~msg ~expected actual = assert_equal string_of_bool msg expected actual
let assert_option ~printer ~msg ~expected actual =
  let printer = function
    | Some x -> "Some (" ^ printer x ^ ")"
    | None   -> "None"
  in
  assert_equal printer msg expected actual
let assert_string_option ~msg ~expected actual = assert_option (fun s -> s) msg expected actual

(** Use the examples from the API documentation to make sure we created the correct atd
    definitions *)
let tests = [
  "AvailablePhoneNumbers/Local", (fun () ->
    let open Available_phone_numbers_local_j in
    let r = response_of_string
      "{
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACde6f1e11047ebd6fe7a55f120be3a900\\/AvailablePhoneNumbers\\/US\\/Local.json?AreaCode=510\",
    \"available_phone_numbers\": [
        {
            \"friendly_name\": \"(510) 564-7903\",
            \"phone_number\": \"+15105647903\",
            \"lata\": \"722\",
            \"rate_center\": \"OKLD TRNID\",
            \"latitude\": \"37.780000\",
            \"longitude\": \"-122.380000\",
            \"region\": \"CA\",
            \"postal_code\": \"94703\",
            \"iso_country\": \"US\"
        },
        {
            \"friendly_name\": \"(510) 488-4379\",
            \"phone_number\": \"+15104884379\",
            \"lata\": \"722\",
            \"rate_center\": \"OKLD FRTVL\",
            \"latitude\": \"37.780000\",
            \"longitude\": \"-122.380000\",
            \"region\": \"CA\",
            \"postal_code\": \"94602\",
            \"iso_country\": \"US\"
        }
     ]
}
"
    in
    assert_int ~msg:"List.length" ~expected:2 (List.length r.available_phone_numbers);

    let r = response_of_string
      "{
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACde6f1e11047ebd6fe7a55f120be3a900\\/AvailablePhoneNumbers\\/US\\/Local.json?Contains=510555****\",
    \"available_phone_numbers\": [
        {
            \"friendly_name\": \"(510) 555-1214\",
            \"phone_number\": \"+15105551214\",
            \"lata\": \"722\",
            \"rate_center\": \"OKLD0349T\",
            \"latitude\": \"37.806940\",
            \"longitude\": \"-122.270360\",
            \"region\": \"CA\",
            \"postal_code\": \"94612\",
            \"iso_country\": \"US\"
        }
    ]
}
"
    in
    assert_int ~msg:"List.length" ~expected:1 (List.length r.available_phone_numbers);
  );
  "AvailablePhoneNumbers/TollFree", (fun () ->
    let open Available_phone_numbers_tollfree_j in
    let r = response_of_string
"{
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACde6f1e11047ebd6fe7a55f120be3a900\\/AvailablePhoneNumbers\\/US\\/TollFree.json\",
    \"available_phone_numbers\": [
        {
            \"friendly_name\": \"(866) 583-8815\",
            \"phone_number\": \"+18665838815\",
            \"iso_country\": \"US\"
        },
        {
            \"friendly_name\": \"(866) 583-0795\",
            \"phone_number\": \"+18665830795\",
            \"iso_country\": \"US\"
        }
    ]
}"
    in
    assert_int ~msg:"List.length" ~expected:2 (List.length r.available_phone_numbers);
  );
  ("OutgoingCallerIds - page", fun () ->
    let open Outgoing_caller_ids_j in
    let r = page_of_string
"{
    \"page\": 0,
    \"num_pages\": 1,
    \"page_size\": 50,
    \"total\": 1,
    \"start\": 0,
    \"end\": 0,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/OutgoingCallerIds.json\",
    \"first_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/OutgoingCallerIds.json?Page=0&PageSize=50\",
    \"previous_page_uri\": null,
    \"next_page_uri\": null,
    \"last_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/OutgoingCallerIds.json?Page=0&PageSize=50\",
    \"outgoing_caller_ids\": [
        {
            \"sid\": \"PNe905d7e6b410746a0fb08c57e5a186f3\",
            \"account_sid\": \"AC228ba7a5fe4238be081ea6f3c44186f3\",
            \"friendly_name\": \"(510) 555-5555\",
            \"phone_number\": \"+15105555555\",
            \"date_created\": \"Tue, 27 Jul 2010 20:21:11 +0000\",
            \"date_updated\": \"Tue, 27 Jul 2010 20:21:11 +0000\",
            \"uri\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/OutgoingCallerIds\\/PNe905d7e6b410746a0fb08c57e5a186f3.json\"
        }
    ]
}"
    in
    assert_int ~msg:"page List.length" ~expected:1 (List.length r.outgoing_caller_ids)
  );
  ("OutgoingCallerIds - get (t)", fun () ->
    let open Outgoing_caller_ids_j in
    let r = t_of_string
"{
    \"sid\": \"PNe905d7e6b410746a0fb08c57e5a186f3\",
    \"account_sid\": \"AC228ba7a5fe4238be081ea6f3c44186f3\",
    \"friendly_name\": \"(510) 555-5555\",
    \"phone_number\": \"+15105555555\",
    \"date_created\": \"Tue, 27 Jul 2010 20:21:11 +0000\",
    \"date_updated\": \"Tue, 27 Jul 2010 20:21:11 +0000\",
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/OutgoingCallerIds\\/PNe905d7e6b410746a0fb08c57e5a186f3.json\"
}"
    in
    assert_string ~msg:"t" ~expected:"(510) 555-5555" r.friendly_name
  );
  ("OutgoingCallerIds - post (post_result)", fun () ->
    let open Outgoing_caller_ids_j in
    let r = post_result_of_string
"{
    \"account_sid\": \"AC228ba5e5fede1b49e100272a8640f438\",
    \"phone_number\": \"+14158675309\",
    \"friendly_name\": \"My Home Phone Number\",
    \"validation_code\": 123456
}"
    in
    assert_string ~msg:"post_result" ~expected:"My Home Phone Number" r.post_friendly_name
  );
  ("IncomingPhoneNumbers - get", fun () ->
    let open Incoming_phone_numbers_j in
    let r = t_of_string
"{
    \"sid\": \"PN2a0747eba6abf96b7e3c3ff0b4530f6e\",
    \"account_sid\": \"ACdc5f1e11047ebd6fe7a55f120be3a900\",
    \"friendly_name\": \"My Company Line\",
    \"phone_number\": \"+15105647903\",
    \"voice_url\": \"http://mycompany.com/handleNewCall.php\",
    \"voice_method\": \"POST\",
    \"voice_fallback_url\": null,
    \"voice_fallback_method\": \"POST\",
    \"status_callback\": null,
    \"status_callback_method\": null,
    \"voice_caller_id_lookup\": null,
    \"voice_application_sid\": null,
    \"date_created\": \"Mon, 16 Aug 2010 23:00:23 +0000\",
    \"date_updated\": \"Mon, 16 Aug 2010 23:00:23 +0000\",
    \"sms_url\": null,
    \"sms_method\": \"POST\",
    \"sms_fallback_url\": null,
    \"sms_fallback_method\": \"GET\",
    \"sms_application_sid\": \"AP9b2e38d8c592488c397fc871a82a74ec\",
    \"capabilities\": {
        \"voice\": null,
        \"sms\": null
    },
    \"api_version\": \"2010-04-01\",
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/IncomingPhoneNumbers\\/PN2a0747eba6abf96b7e3c3ff0b4530f6e.json\"
}"
    in
    assert_string ~msg:"friendly_name" ~expected:"My Company Line" r.friendly_name;
    assert_bool ~msg:"voice_caller_id_lookup" ~expected:false r.voice_caller_id_lookup;
    assert_bool ~msg:"capabilities.voice" ~expected:true r.capabilities.voice;
    assert_string_option ~msg:"voice_fallback_url" ~expected:None r.voice_fallback_url;
    assert_string_option ~msg:"voice_fallback_method" ~expected:(Some "POST") r.voice_fallback_method
  );
  ("IncomingPhoneNumbers - post (update)", fun () ->
    let open Incoming_phone_numbers_j in
    let r = t_of_string
"{
    \"sid\": \"PN2a0747eba6abf96b7e3c3ff0b4530f6e\",
    \"account_sid\": \"AC755325d45d80675a4727a7a54e1b4ce4\",
    \"friendly_name\": \"My Company Line\",
    \"phone_number\": \"+15105647903\",
    \"voice_url\": \"http://myapp.com/awesome\",
    \"voice_method\": \"POST\",
    \"voice_fallback_url\": null,
    \"voice_fallback_method\": \"POST\",
    \"voice_caller_id_lookup\": null,
    \"voice_application_sid\": null,
    \"date_created\": \"Mon, 16 Aug 2010 23:00:23 +0000\",
    \"date_updated\": \"Mon, 16 Aug 2010 23:00:23 +0000\",
    \"sms_url\": \"http://myapp.com/awesome\",
    \"sms_method\": \"POST\",
    \"sms_fallback_url\": null,
    \"sms_fallback_method\": \"GET\",
    \"sms_application_sid\": null,
    \"capabilities\": {
        \"voice\": null,
        \"sms\": null
    },
    \"status_callback\": null,
    \"status_callback_method\": null,
    \"api_version\": \"2010-04-01\",
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC755325d45d80675a4727a7a54e1b4ce4\\/IncomingPhoneNumbers\\/PN2a0747eba6abf96b7e3c3ff0b4530f6e.json\"
}"
    in
    assert_string ~msg:"phone_number" ~expected:"+15105647903" r.phone_number
  );
  ("IncomingPhoneNumbers -- list", fun () ->
    let open Incoming_phone_numbers_j in
    let r = page_of_string
"{
    \"page\": 0,
    \"num_pages\": 1,
    \"page_size\": 50,
    \"total\": 6,
    \"start\": 0,
    \"end\": 5,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/IncomingPhoneNumbers.json\",
    \"first_page_uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/IncomingPhoneNumbers.json?Page=0&PageSize=50\",
    \"previous_page_uri\": null,
    \"next_page_uri\": null,
    \"last_page_uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/IncomingPhoneNumbers.json?Page=0&PageSize=50\",
    \"incoming_phone_numbers\": [
        {
            \"sid\": \"PN3f94c94562ac88dccf16f8859a1a8b25\",
            \"account_sid\": \"ACdc5f1e11047ebd6fe7a55f120be3a900\",
            \"friendly_name\": \"Long Play\",
            \"phone_number\": \"+14152374451\",
            \"voice_url\": \"http:\\/\\/demo.twilio.com\\/long\",
            \"voice_method\": \"GET\",
            \"voice_fallback_url\": null,
            \"voice_fallback_method\": null,
            \"voice_caller_id_lookup\": null,
            \"voice_application_sid\": null,
            \"date_created\": \"Thu, 13 Nov 2008 07:56:24 +0000\",
            \"date_updated\": \"Thu, 13 Nov 2008 08:45:58 +0000\",
            \"sms_url\": null,
            \"sms_method\": null,
            \"sms_fallback_url\": null,
            \"sms_fallback_method\": null,
            \"sms_application_sid\": \"AP9b2e38d8c592488c397fc871a82a74ec\",
            \"capabilities\": {
                \"voice\": true,
                \"sms\": false
            },
            \"status_callback\": null,
            \"status_callback_method\": null,
            \"api_version\": \"2010-04-01\",
            \"uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/IncomingPhoneNumbers\\/PN3f94c94562ac88dccf16f8859a1a8b25.json\"
        }
    ]
}"
    in
    assert_int ~msg:"List.length" ~expected:1 (List.length r.incoming_phone_numbers)
  );
  ("Applications - get", fun () ->
    let open Applications_j in
    let r = t_of_string
"{
    \"sid\": \"AP2a0747eba6abf96b7e3c3ff0b4530f6e\",
    \"date_created\": \"Mon, 16 Aug 2010 23:00:23 +0000\",
    \"date_updated\": \"Mon, 16 Aug 2010 23:00:23 +0000\",
    \"account_sid\": \"ACdc5f1e11047ebd6fe7a55f120be3a900\",
    \"friendly_name\": \"Phone Me\",
    \"api_version\": \"2010-04-01\",
    \"voice_url\": \"http://mycompany.com/handleNewCall.php\",
    \"voice_method\": \"POST\",
    \"voice_fallback_url\": null,
    \"voice_fallback_method\": \"POST\",
    \"status_callback\": null,
    \"status_callback_method\": null,
    \"voice_caller_id_lookup\": null,
    \"sms_url\": null,
    \"sms_method\": \"POST\",
    \"sms_fallback_url\": null,
    \"sms_fallback_method\": \"GET\",
    \"sms_status_callback\": null,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/Applications\\/AP2a0747eba6abf96b7e3c3ff0b4530f6e.json\"
}"
    in
    assert_string_option ~msg:"sms_fallback_method" ~expected:(Some "GET") r.sms_fallback_method
  );
  ("Applications - post", fun () ->
    let open Applications_j in
    let r = t_of_string
"{
    \"sid\": \"AP2a0747eba6abf96b7e3c3ff0b4530f6e\",
    \"date_created\": \"Mon, 16 Aug 2010 23:00:23 +0000\",
    \"date_updated\": \"Mon, 16 Aug 2010 23:00:23 +0000\",
    \"account_sid\": \"AC755325d45d80675a4727a7a54e1b4ce4\",
    \"friendly_name\": \"Phone Me\",
    \"api_version\": \"2010-04-01\",
    \"voice_url\": \"http://myapp.com/awesome\",
    \"voice_method\": \"POST\",
    \"voice_fallback_url\": null,
    \"voice_fallback_method\": \"POST\",
    \"status_callback\": null,
    \"status_callback_method\": null,
    \"voice_caller_id_lookup\": null,
    \"sms_url\": \"http://myapp.com/awesome\",
    \"sms_method\": \"POST\",
    \"sms_fallback_url\": null,
    \"sms_fallback_method\": \"GET\",
    \"sms_status_callback\": null,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC755325d45d80675a4727a7a54e1b4ce4\\/Applications\\/AP2a0747eba6abf96b7e3c3ff0b4530f6e.json\"
}"
    in
    assert_string_option ~msg:"sms_url" ~expected:(Some "http://myapp.com/awesome") r.sms_url
  );
  ("Applications - list", fun () ->
    let open Applications_j in
    let r = page_of_string
"{
    \"page\": 0,
    \"num_pages\": 1,
    \"page_size\": 50,
    \"total\": 6,
    \"start\": 0,
    \"end\": 5,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/Applications.json\",
    \"first_page_uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/Applications.json?Page=0&PageSize=50\",
    \"previous_page_uri\": null,
    \"next_page_uri\": null,
    \"last_page_uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/Applications.json?Page=0&PageSize=50\",
    \"applications\": [
        {
            \"sid\": \"AP3f94c94562ac88dccf16f8859a1a8b25\",
            \"date_created\": \"Thu, 13 Nov 2008 07:56:24 +0000\",
            \"date_updated\": \"Thu, 13 Nov 2008 08:45:58 +0000\",
            \"account_sid\": \"ACdc5f1e11047ebd6fe7a55f120be3a900\",
            \"friendly_name\": \"Long Play\",
            \"api_version\": \"2010-04-01\",
            \"voice_url\": \"http:\\/\\/demo.twilio.com\\/long\",
            \"voice_method\": \"GET\",
            \"voice_fallback_url\": null,
            \"voice_fallback_method\": null,
            \"status_callback\": null,
            \"status_callback_method\": null,
            \"voice_caller_id_lookup\": null,
            \"sms_url\": null,
            \"sms_method\": null,
            \"sms_fallback_url\": null,
            \"sms_fallback_method\": null,
            \"sms_status_callback\": null,
            \"uri\": \"\\/2010-04-01\\/Accounts\\/ACdc5f1e11047ebd6fe7a55f120be3a900\\/Applications\\/AP3f94c94562ac88dccf16f8859a1a8b25.json\"
        }
    ]
}"
    in
    assert_int ~msg:"List.length" ~expected:1 (List.length r.applications)
  );
  ("ConnectApps - get", fun () ->
    let open Connect_apps_j in
    let r = t_of_string
"{
    \"sid\": \"CNb989fdd207b04d16aee578018ef5fd93\",
    \"account_sid\": \"AC72d87bea57556989c033c644f6270b8e\",
    \"friendly_name\": \"My awesome ConnectApp\",
    \"description\": \"An amazing TwilioConnect application that does amazing things!\",
    \"company_name\": \"My Company\",
    \"homepage_url\": \"http://www.mycompany.com\",
    \"authorize_redirect_url\": \"https://www.mycompany.com/connect_authorize\",
    \"deauthorize_callback_url\": \"https://www.mycompany.com/connect_deauthorize\",
    \"deauthorize_callback_method\": \"POST\",
    \"permissions\": [\"get-all\",\"post-all\"]
}"
    in
    let printer = function
      | `Get_all -> "Get_all"
      | `Post_all -> "Post_all"
    in
    assert_int ~msg:"List.length" ~expected:2 (List.length r.permissions);
    let a, b =
      match r.permissions with
        | [a;b] -> a,b
        | _     -> failwith "Whoa! we assert List.length is 2 above"
    in
    assert_equal ~printer ~msg:"permission a" ~expected:`Get_all a;
    assert_equal ~printer ~msg:"permission b" ~expected:`Post_all b
  );
  ("ConnectApps - list", fun () ->
    let open Connect_apps_j in
    let r = page_of_string
"{
  \"authorized_connect_apps\": [
    {
      \"sid\": \"CNb989fdd207b04d16aee578018ef5fd93\",
      \"account_sid\": \"AC72d87bea57556989c033c644f6270b8e\",
      \"friendly_name\": \"My awesome ConnectApp\",
      \"description\": \"An amazing TwilioConnect application that does amazing things!\",
      \"company_name\": \"My Company\",
      \"homepage_url\": \"http://www.mycompany.com\",
      \"authorize_redirect_url\": \"https://www.mycompany.com/connect_authorize\",
      \"deauthorize_callback_url\": \"https://www.mycompany.com/connect_deauthorize\",
      \"deauthorize_callback_method\": \"POST\",
      \"permissions\": [\"get-all\",\"post-all\"]
    }
  ],
  \"page\": 0,
  \"num_pages\": 1,
  \"page_size\": 50,
  \"total\": 3,
  \"start\": 0,
  \"end\": 2,
  \"uri\": \"\\/2010-04-01\\/Accounts\\/AC81e0ca4b0af06b833b6726957613c5d4\\/AuthorizedConnectApps\\/.json\",
  \"first_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC81e0ca4b0af06b833b6726957613c5d4\\/AuthorizedConnectApps\\/.json?Page=0&PageSize=50\",
  \"previous_page_uri\": null,
  \"next_page_uri\": null,
  \"last_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC81e0ca4b0af06b833b6726957613c5d4\\/AuthorizedConnectApps\\/.json?Page=0&PageSize=50\"
}"
    in
    assert_int ~msg:"List.length" ~expected:1 (List.length r.authorized_connect_apps)
  );
  ("AuthorizedConnectApps - get", fun () ->
    let open Authorized_connect_apps_j in
    let r = t_of_string
"{
  \"connect_app_sid\": \"CN47260e643654388faabe8aaa18ea6756\",
  \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
  \"permissions\": [\"get-all\", \"post-all\"],
  \"connect_app_friendly_name\": \"My Connect App\",
  \"connect_app_description\": null,
  \"connect_app_company_name\": \"My Company\",
  \"connect_app_homepage_url\": \"http://www.mycompany.com\"
}"
    in
    assert_int ~msg:"permissions length" ~expected:2 (List.length r.permissions)
  );
  ("AuthorizedConnectApps - list", fun () ->
    let open Authorized_connect_apps_j in
    let r = page_of_string
"{
  \"authorized_connect_apps\": [
    {
      \"connect_app_sid\": \"CNb989fdd207b04d16aee578018ef5fd93\",
      \"account_sid\": \"AC828fd6e37bee469a9aee33475d67db2c\",
      \"permissions\": [\"get-all\", \"post-all\"],
      \"connect_app_friendly_name\": \"Jenny Tracker\",
      \"connect_app_description\": null,
      \"connect_app_company_name\": \"Tommy PI\",
      \"connect_app_homepage_url\": \"http://www.tommypi.com\"
    }
  ],
  \"page\": 0,
  \"num_pages\": 1,
  \"page_size\": 50,
  \"total\": 3,
  \"start\": 0,
  \"end\": 2,
  \"uri\": \"\\/2010-04-01\\/Accounts\\/AC81e0ca4b0af06b833b6726957613c5d4\\/AuthorizedConnectApps\\/.json\",
  \"first_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC81e0ca4b0af06b833b6726957613c5d4\\/AuthorizedConnectApps\\/.json?Page=0&PageSize=50\",
  \"previous_page_uri\": null,
  \"next_page_uri\": null,
  \"last_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC81e0ca4b0af06b833b6726957613c5d4\\/AuthorizedConnectApps\\/.json?Page=0&PageSize=50\"
}"
    in
    assert_int ~msg:"List.length" ~expected:1 (List.length r.authorized_connect_apps)
  );
  ("Transcription - get", fun () ->
    let open Transcriptions_j in
    let r = t_of_string
"{
    \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
    \"api_version\": \"2008-08-01\",
    \"date_created\": \"Mon, 26 Jul 2010 00:09:58 +0000\",
    \"date_updated\": \"Mon, 26 Jul 2010 00:10:25 +0000\",
    \"duration\": \"6\",
    \"price\": \"-0.05000\",
    \"recording_sid\": \"REca11f06dc31b5515a2dfb1f5134361f2\",
    \"sid\": \"TR8c61027b709ffb038236612dc5af8723\",
    \"status\": \"completed\",
    \"transcription_text\": \"Tommy? Tommy is that you? I told you never to call me again.\",
    \"type\": \"fast\",
    \"uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/Transcriptions/TR8c61027b709ffb038236612dc5af8723.json\"
}"
    in
    let printer = function
      | `Completed -> "completed"
      | `In_progress -> "in-progress"
      | `Failed -> "failed"
    in
    assert_equal ~printer ~msg:"status" ~expected:`Completed r.status;
    assert_string ~msg:"type" ~expected:"fast" r.transcription_type
  );
  ("Transcription - list", fun () ->
    let open Transcriptions_j in
    let r = page_of_string
"{
    \"end\": 49,
    \"num_pages\": 3,
    \"page\": 0,
    \"page_size\": 50,
    \"previous_page_uri\": null,
    \"start\": 0,
    \"total\": 150,
    \"first_page_uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/Transcriptions.json?Page=0&PageSize=50\",
    \"last_page_uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/Transcriptions.json?Page=2&PageSize=50\",
    \"next_page_uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/Transcriptions.json?Page=1&PageSize=50\",
    \"uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/Transcriptions.json\",
    \"transcriptions\": [
        {
            \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
            \"api_version\": \"2010-04-01\",
            \"date_created\": \"Mon, 26 Jul 2010 00:09:58 +0000\",
            \"date_updated\": \"Mon, 26 Jul 2010 00:10:25 +0000\",
            \"duration\": \"6\",
            \"price\": \"-0.05000\",
            \"recording_sid\": \"REca11f06dc31b5515a2dfb1f5134361f2\",
            \"sid\": \"TR8c61027b709ffb038236612dc5af8723\",
            \"status\": \"completed\",
            \"transcription_text\": \"Tommy? Tommy is that you? I told you never to call me again.\",
            \"type\": \"fast\",
            \"uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/Transcriptions/TR8c61027b709ffb038236612dc5af8723.json\"
        }
    ]
}"
    in
    assert_string ~msg:"duration" ~expected:"6" (List.hd r.transcriptions).duration
  );
  ("Recordings - list", fun () ->
    let open Recordings_j in
    let r = page_of_string
"{
    \"start\": 0,
    \"end\": 49,
    \"total\": 527,
    \"num_pages\": 11,
    \"page\": 0,
    \"page_size\": 50,
    \"uri\": \"/2010-04-01/Accounts/ACda6f1e11047ebd6fe7a55f120be3a900/Recordings.json\",
    \"first_page_uri\": \"/2010-04-01/Accounts/ACda6f1e11047ebd6fe7a55f120be3a900/Recordings.json?Page=0&PageSize=50\",
    \"last_page_uri\": \"/2010-04-01/Accounts/ACda6f1e11047ebd6fe7a55f120be3a900/Recordings.json?Page=10&PageSize=50\",
    \"previous_page_uri\": null,
    \"next_page_uri\": \"/2010-04-01/Accounts/ACda6f1e11047ebd6fe7a55f120be3a900/Recordings.json?Page=1&PageSize=50\",
    \"recordings\": [
        {
            \"account_sid\": \"ACda6f1e11047ebd6fe7a55f120be3a900\",
            \"api_version\": \"2008-08-01\",
            \"call_sid\": \"CA8dfedb55c129dd4d6bd1f59af9d11080\",
            \"date_created\": \"Fri, 17 Jul 2009 01:52:49 +0000\",
            \"date_updated\": \"Fri, 17 Jul 2009 01:52:49 +0000\",
            \"duration\": \"1\",
            \"sid\": \"RE557ce644e5ab84fa21cc21112e22c485\",
            \"uri\": \"/2010-04-01/Accounts/ACda6f1e11047ebd6fe7a55f120be3a900/Recordings/RE557ce644e5ab84fa21cc21112e22c485.json\"
        }
    ]
}"
    in
    let r = List.hd r.recordings in
    assert_string ~msg:"duration" ~expected:"1" r.duration
  );
  ("Notifications - get", fun () ->
    let open Notifications_j in
    let r = t_of_string
"{
    \"sid\": \"NO5a7a84730f529f0a76b3e30c01315d1a\",
    \"account_sid\": \"ACda6f1e11047ebd6fe7a55f120be3a900\",
    \"call_sid\": \"CAa8857b0dcc71b4909aced594f7f87453\",
    \"log\": \"0\",
    \"error_code\": \"11205\",
    \"more_info\": \"http:\\/\\/www.twilio.com\\/docs\\/errors\\/11205\",
    \"message_text\": \"EmailNotification=false&LogLevel=ERROR&sourceComponent=13400&Msg=HTTP+Connection+Failure+-+Read+timed+out&ErrorCode=11205&msg=HTTP+Connection+Failure+-+Read+timed+out&url=4min19secs.mp3\",
    \"message_date\": \"Tue, 09 Feb 2010 01:23:53 +0000\",
    \"response_body\": \"<!--?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?-->\\n<Response>\\n\\t<Play>4min19secs.mp3<\\/Play>\\n<\\/Response>\\n\",
    \"request_method\": \"GET\",
    \"request_url\": \"http:\\/\\/demo.twilio.com\\/welcome\",
    \"request_variables\": \"AccountSid=ACda6f1e11047ebd6fe7a55f120be3a900&CallStatus=in-progress&Called=4152374451&CallerCountry=US&CalledZip=94937&CallerCity=&Caller=4150000000&CalledCity=INVERNESS&CalledCountry=US&DialStatus=answered&CallerState=California&CallSid=CAa8857b0dcc71b4909aced594f7f87453&CalledState=CA&CallerZip=\",
    \"response_headers\": \"Date=Tue%2C+09+Feb+2010+01%3A23%3A38+GMT&Vary=Accept-Encoding&Content-Length=91&Content-Type=text%2Fxml&Accept-Ranges=bytes&Server=Apache%2F2.2.3+%28CentOS%29&X-Powered-By=PHP%2F5.1.6\",
    \"date_created\": \"Tue, 09 Feb 2010 01:23:53 +0000\",
    \"api_version\": \"2008-08-01\",
    \"date_updated\": \"Tue, 09 Feb 2010 01:23:53 +0000\",
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACda6f1e11047ebd6fe7a55f120be3a900\\/Notifications\\/NO5a7a84730f529f0a76b3e30c01315d1a.json\"
}"
    in
    assert_string ~msg:"error_code" ~expected:"11205" r.error_code;
  );
  ("Notifications - list", fun () ->
    let open Notifications_j in
    let r = page_of_string
"{
    \"page\": 0,
    \"num_pages\": 25,
    \"page_size\": 50,
    \"total\": 1224,
    \"start\": 0,
    \"end\": 49,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/ACda6f1e11047ebd6fe7a55f120be3a900\\/Notifications.json\",
    \"first_page_uri\": \"\\/2010-04-01\\/Accounts\\/ACda6f1e11047ebd6fe7a55f120be3a900\\/Notifications.json?Page=0&PageSize=50\",
    \"previous_page_uri\": null,
    \"next_page_uri\": \"\\/2010-04-01\\/Accounts\\/ACda6f1e11047ebd6fe7a55f120be3a900\\/Notifications.json?Page=1&PageSize=50\",
    \"last_page_uri\": \"\\/2010-04-01\\/Accounts\\/ACda6f1e11047ebd6fe7a55f120be3a900\\/Notifications.json?Page=24&PageSize=50\",
    \"notifications\": [
        {
            \"sid\": \"NO5a7a84730f529f0a76b3e30c01315d1a\",
            \"account_sid\": \"ACda6f1e11047ebd6fe7a55f120be3a900\",
            \"call_sid\": \"CAa8857b0dcc71b4909aced594f7f87453\",
            \"log\": \"0\",
            \"error_code\": \"11205\",
            \"more_info\": \"http:\\/\\/www.twilio.com\\/docs\\/errors\\/11205\",
            \"message_text\": \"EmailNotification=false&LogLevel=ERROR&sourceComponent=13400&Msg=HTTP+Connection+Failure+-+Read+timed+out&ErrorCode=11205&msg=HTTP+Connection+Failure+-+Read+timed+out&url=4min19secs.mp3\",
            \"message_date\": \"Tue, 09 Feb 2010 01:23:53 +0000\",
            \"request_method\": \"POST\",
            \"request_url\": \"http:\\/\\/demo.twilio.com\\/welcome\",
            \"date_created\": \"Tue, 09 Feb 2010 01:23:53 +0000\",
            \"api_version\": \"2008-08-01\",
            \"date_updated\": \"Tue, 09 Feb 2010 01:23:53 +0000\",
            \"uri\": \"\\/2010-04-01\\/Accounts\\/ACda6f1e11047ebd6fe7a55f120be3a900\\/Notifications\\/NO5a7a84730f529f0a76b3e30c01315d1a.json\"
        }
    ]
}"
    in
    assert_int ~msg:"List.length" ~expected:1 (List.length r.notifications)
  );
  ("Calls  - get", fun () ->
    let open Calls_j in
    let r = t_of_string
"{
    \"sid\": \"CAe1644a7eed5088b159577c5802d8be38\",
    \"date_created\": \"Tue, 10 Aug 2010 08:02:17 +0000\",
    \"date_updated\": \"Tue, 10 Aug 2010 08:02:47 +0000\",
    \"parent_call_sid\": null,
    \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
    \"to\": \"+14153855708\",
    \"from\": \"+14158141819\",
    \"phone_number_sid\": null,
    \"status\": \"completed\",
    \"start_time\": \"Tue, 10 Aug 2010 08:02:31 +0000\",
    \"end_time\": \"Tue, 10 Aug 2010 08:02:47 +0000\",
    \"duration\": \"16\",
    \"price\": \"-0.03000\",
    \"direction\": \"outbound-api\",
    \"answered_by\": null,
    \"api_version\": \"2008-08-01\",
    \"annotation\": null,
    \"forwarded_from\": null,
    \"caller_name\": null,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38.json\",
    \"subresource_uris\":{
        \"notifications\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38\\/Notifications.json\",
        \"recordings\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38\\/Recordings.json\"
    }
}"
    in
    let printer = function
      | `Inbound -> "in"
      | `Outbound_api -> "api"
      | `Outbound_dial -> "dial"
    in
    assert_equal ~printer ~msg:"direction" ~expected:`Outbound_api r.direction;
    let len =
      match r.subresource_uris.notifications with
        | Some s -> String.length s
        | None   -> 0
    in
    assert_bool ~msg:"notifications length" ~expected:true (len > 0)
  );
  ("Calls - list", fun () ->
    let open Calls_j in
    let r = page_of_string
"{
    \"page\": 0,
    \"num_pages\": 3,
    \"page_size\": 50,
    \"total\": 147,
    \"start\": 0,
    \"end\": 49,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC5ef877a5fe4238be081ea6f3c44186f3\\/Calls.json\",
    \"first_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC5ef877a5fe4238be081ea6f3c44186f3\\/Calls.json?Page=0&PageSize=50\",
    \"previous_page_uri\": null,
    \"next_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC5ef877a5fe4238be081ea6f3c44186f3\\/Calls.json?Page=1&PageSize=50\",
    \"last_page_uri\": \"\\/2010-04-01\\/Accounts\\/AC5ef877a5fe4238be081ea6f3c44186f3\\/Calls.json?Page=2&PageSize=50\",
    \"calls\": [
        {
            \"sid\": \"CA92d4405c9237c4ea04b56cbda88e128c\",
            \"date_created\": \"Fri, 13 Aug 2010 01:16:22 +0000\",
            \"date_updated\": \"Fri, 13 Aug 2010 01:16:22 +0000\",
            \"parent_call_sid\": null,
            \"account_sid\": \"AC5ef877a5fe4238be081ea6f3c44186f3\",
            \"to\": \"+15304551166\",
            \"from\": \"+15105555555\",
            \"phone_number_sid\": \"PNe2d8e63b37f46f2adb16f228afdb9058\",
            \"status\": \"queued\",
            \"start_time\": null,
            \"end_time\": null,
            \"duration\": null,
            \"price\": null,
            \"direction\": \"outbound-api\",
            \"answered_by\": null,
            \"api_version\": \"2010-04-01\",
            \"forwarded_from\": null,
            \"caller_name\": null,
            \"uri\": \"\\/2010-04-01\\/Accounts\\/AC5ef877a5fe4238be081ea6f3c44186f3\\/Calls\\/CA92d4405c9237c4ea04b56cbda88e128c.json\",
            \"subresource_uris\": {
                \"notifications\": \"\\/2010-04-01\\/Accounts\\/AC5ef877a5fe4238be081ea6f3c44186f3\\/Calls\\/CA92d4405c9237c4ea04b56cbda88e128c\\/Notifications.json\",
                \"recordings\": \"\\/2010-04-01\\/Accounts\\/AC5ef877a5fe4238be081ea6f3c44186f3\\/Calls\\/CA92d4405c9237c4ea04b56cbda88e128c\\/Recordings.json\"
            }
        }
    ]
}"
    in
    assert_int ~msg:"List.length" ~expected:1 (List.length r.calls)
  );
  ("Calls -- making calls example 1", fun () ->
    let open Calls_j in
    let r = t_of_string
"{
    \"sid\": \"CAa346467ca321c71dbd5e12f627deb854\",
    \"date_created\": \"Thu, 19 Aug 2010 00:12:15 +0000\",
    \"date_updated\": \"Thu, 19 Aug 2010 00:12:15 +0000\",
    \"parent_call_sid\": null,
    \"account_sid\": \"AC228ba7a5fe4238be081ea6f3c44186f3\",
    \"to\": \"+14155551212\",
    \"formatted_to\": \"(415) 555-1212\",
    \"from\": \"+14158675309\",
    \"formatted_from\": \"(415) 867-5309\",
    \"phone_number_sid\": \"PNd6b0e1e84f7b117332aed2fd2e5bbcab\",
    \"status\": \"queued\",
    \"start_time\": null,
    \"end_time\": null,
    \"duration\": null,
    \"price\": null,
    \"direction\": \"outbound-api\",
    \"answered_by\": null,
    \"api_version\": \"2010-04-01\",
    \"forwarded_from\": null,
    \"caller_name\": null,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAa346467ca321c71dbd5e12f627deb854.json\",
    \"subresource_uris\": {
        \"notifications\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAa346467ca321c71dbd5e12f627deb854\\/Notifications.json\",
        \"recordings\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAa346467ca321c71dbd5e12f627deb854\\/Recordings.json\"
    }
}"
    in
    assert_string_option ~msg:"start_time" ~expected:None r.start_time
  );
  ("Calls -- making calls example 2", fun () ->
    let open Calls_j in
    let r = t_of_string
"{
    \"sid\": \"CAa346467ca321c71dbd5e12f627deb854\",
    \"date_created\": \"Thu, 19 Aug 2010 00:12:15 +0000\",
    \"date_updated\": \"Thu, 19 Aug 2010 00:12:15 +0000\",
    \"parent_call_sid\": null,
    \"account_sid\": \"AC228ba7a5fe4238be081ea6f3c44186f3\",
    \"to\": \"client:tommy\",
    \"formatted_to\": \"tommy\",
    \"from\": \"+14158675309\",
    \"formatted_from\": \"(415) 867-5309\",
    \"phone_number_sid\": \"PNd6b0e1e84f7b117332aed2fd2e5bbcab\",
    \"status\": \"queued\",
    \"start_time\": null,
    \"end_time\": null,
    \"duration\": null,
    \"price\": null,
    \"direction\": \"outbound-api\",
    \"answered_by\": null,
    \"api_version\": \"2010-04-01\",
    \"forwarded_from\": null,
    \"caller_name\": null,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAa346467ca321c71dbd5e12f627deb854.json\",
    \"subresource_uris\": {
        \"notifications\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAa346467ca321c71dbd5e12f627deb854\\/Notifications.json\",
        \"recordings\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAa346467ca321c71dbd5e12f627deb854\\/Recordings.json\"
    }
}"
    in
    assert_string_option ~msg:"formatted_to" ~expected:(Some "tommy") r.formatted_to;
    assert_string ~msg:"to" ~expected:"client:tommy" r.to_number
  );
  ("Calls -- making calls example 3", fun () ->
    let open Calls_j in
    let r = t_of_string
"{
    \"sid\": \"CAc7a1fe47b14637f42fd94274d1907a1d\",
    \"date_created\": \"Thu, 19 Aug 2010 00:12:15 +0000\",
    \"date_updated\": \"Thu, 19 Aug 2010 00:12:15 +0000\",
    \"parent_call_sid\": null,
    \"account_sid\": \"AC228ba7a5fe4238be081ea6f3c44186f3\",
    \"to\": \"+14155551212\",
    \"formatted_to\": \"(415) 555-1212\",
    \"from\": \"+18668675309\",
    \"formatted_from\": \"(866) 867-5309\",
    \"phone_number_sid\": \"PNd6b0e1e84f7b117332aed2fd2e5bbcab\",
    \"status\": \"queued\",
    \"start_time\": null,
    \"end_time\": null,
    \"duration\": null,
    \"price\": null,
    \"direction\": \"outbound-api\",
    \"answered_by\": null,
    \"api_version\": \"2010-04-01\",
    \"forwarded_from\": null,
    \"caller_name\": null,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAc7a1fe47b14637f42fd94274d1907a1d.json\",
    \"subresource_uris\": {
        \"notifications\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAc7a1fe47b14637f42fd94274d1907a1d\\/Notifications.json\",
        \"recordings\": \"\\/2010-04-01\\/Accounts\\/AC228ba7a5fe4238be081ea6f3c44186f3\\/Calls\\/CAc7a1fe47b14637f42fd94274d1907a1d\\/Recordings.json\"
    }
}"
    in
    assert_string_option ~msg:"formatted_from" ~expected:(Some "(866) 867-5309") r.formatted_from
  );
  ("Calls - modifying example 1", fun () ->
    let open Calls_j in
    let r = t_of_string
"{
    \"sid\": \"CAe1644a7eed5088b159577c5802d8be38\",
    \"date_created\": \"Tue, 10 Aug 2010 08:02:17 +0000\",
    \"date_updated\": \"Tue, 10 Aug 2010 08:02:47 +0000\",
    \"parent_call_sid\": null,
    \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
    \"to\": \"+14153855708\",
    \"from\": \"+14158141819\",
    \"phone_number_sid\": null,
    \"status\": \"in-progress\",
    \"start_time\": \"Tue, 10 Aug 2010 08:02:31 +0000\",
    \"end_time\": \"Tue, 10 Aug 2010 08:02:47 +0000\",
    \"duration\": \"16\",
    \"price\": \"-0.03000\",
    \"direction\": \"outbound-api\",
    \"answered_by\": null,
    \"api_version\": \"2010-04-01\",
    \"annotation\": null,
    \"forwarded_from\": null,
    \"caller_name\": null,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38.json\",
    \"subresource_uris\":{
        \"notifications\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38\\/Notifications.json\",
        \"recordings\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38\\/Recordings.json\"
    }
}"
    in
    assert_string_option ~msg:"answered_by" ~expected:None r.answered_by
  );
  ("Calls - modifying example 2", fun () ->
    let open Calls_j in
    let r = t_of_string
"{
    \"sid\": \"CAe1644a7eed5088b159577c5802d8be38\",
    \"date_created\": \"Tue, 10 Aug 2010 08:02:17 +0000\",
    \"date_updated\": \"Tue, 10 Aug 2010 08:02:47 +0000\",
    \"parent_call_sid\": null,
    \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
    \"to\": \"+14153855708\",
    \"from\": \"+14158141819\",
    \"phone_number_sid\": null,
    \"status\": \"completed\",
    \"start_time\": \"Tue, 10 Aug 2010 08:02:31 +0000\",
    \"end_time\": \"Tue, 10 Aug 2010 08:02:47 +0000\",
    \"duration\": \"16\",
    \"price\": \"-0.03000\",
    \"direction\": \"outbound-api\",
    \"answered_by\": null,
    \"api_version\": \"2010-04-01\",
    \"annotation\": null,
    \"forwarded_from\": null,
    \"caller_name\": null,
    \"uri\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38.json\",
    \"subresource_uris\":{
        \"notifications\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38\\/Notifications.json\",
        \"recordings\": \"\\/2010-04-01\\/Accounts\\/AC5ef872f6da5a21de157d80997a64bd33\\/Calls\\/CAe1644a7eed5088b159577c5802d8be38\\/Recordings.json\"
    }
}"
    in
    let printer = function
      | `Completed -> "completed"
      | _          -> "something else"
    in
    assert_equal ~printer ~msg:"status" ~expected:`Completed r.status
  );
  ("SMS Message - get", fun () ->
    let open Sms_messages_j in
    let r = t_of_string
"{
    \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
    \"api_version\": \"2008-08-01\",
    \"body\": \"Hey Jenny why aren't you returning my calls?\",
    \"date_created\": \"Mon, 16 Aug 2010 03:45:01 +0000\",
    \"date_sent\": \"Mon, 16 Aug 2010 03:45:03 +0000\",
    \"date_updated\": \"Mon, 16 Aug 2010 03:45:03 +0000\",
    \"direction\": \"outbound-api\",
    \"from\": \"+14158141829\",
    \"price\": \"-0.02000\",
    \"sid\": \"SM800f449d0399ed014aae2bcc0cc2f2ec\",
    \"status\": \"sent\",
    \"to\": \"+14159978453\",
    \"uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM800f449d0399ed014aae2bcc0cc2f2ec.json\"
}
"
    in
    assert_string ~msg:"from" ~expected:"+14158141829" r.from_number
  );
  ("SMS Message - list", fun () ->
    let open Sms_messages_j in
    let r = page_of_string
"{
    \"start\": 0,
    \"total\": 261,
    \"num_pages\": 6,
    \"page\": 0,
    \"page_size\": 50,
    \"end\": 49,
    \"uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages.json\",
    \"first_page_uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages.json?Page=0&PageSize=50\",
    \"last_page_uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages.json?Page=5&PageSize=50\",
    \"next_page_uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages.json?Page=1&PageSize=50\",
    \"previous_page_uri\": null,
    \"sms_messages\": [
        {
            \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
            \"api_version\": \"2008-08-01\",
            \"body\": \"Hey Jenny why aren't you returning my calls?\",
            \"date_created\": \"Mon, 16 Aug 2010 03:45:01 +0000\",
            \"date_sent\": \"Mon, 16 Aug 2010 03:45:03 +0000\",
            \"date_updated\": \"Mon, 16 Aug 2010 03:45:03 +0000\",
            \"direction\": \"outbound-api\",
            \"from\": \"+14158141829\",
            \"price\": \"-0.02000\",
            \"sid\": \"SM800f449d0399ed014aae2bcc0cc2f2ec\",
            \"status\": \"sent\",
            \"to\": \"+14159978453\",
            \"uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM800f449d0399ed014aae2bcc0cc2f2ec.json\"
        }
    ]
}"
    in
    assert_int ~msg:"List.length" ~expected:1 (List.length r.sms_messages)
  );
  ("SMS Message -- sending example", fun () ->
    let open Sms_messages_j in
    let r = t_of_string
"{
    \"account_sid\": \"AC5ef872f6da5a21de157d80997a64bd33\",
    \"api_version\": \"2010-04-01\",
    \"body\": \"Jenny please?! I love you <3\",
    \"date_created\": \"Wed, 18 Aug 2010 20:01:40 +0000\",
    \"date_sent\": null,
    \"date_updated\": \"Wed, 18 Aug 2010 20:01:40 +0000\",
    \"direction\": \"outbound-api\",
    \"from\": \"+14158141829\",
    \"price\": null,
    \"sid\": \"SM90c6fc909d8504d45ecdb3a3d5b3556e\",
    \"status\": \"queued\",
    \"to\": \"+14159352345\",
    \"uri\": \"/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM90c6fc909d8504d45ecdb3a3d5b3556e.json\"
}"
    in
    let printer = function
      | `Queued -> "queued"
      | `Sending -> "sending"
      | `Sent -> "sent"
      | `Received -> "received"
      | `Failed -> "failed"
    in
    assert_equal ~printer ~msg:"status" ~expected:`Queued r.status
  );
]

let test_runner tests =
  let progress () =
    output_char stderr '.';
    flush stderr
  in
  List.iter
    (fun (name, fn) ->
      progress ();
      try fn ()
      with e ->
        let msg =
          Printf.sprintf "\n\nIn test [%s]:\n%s\n%s"
            name
            (Printexc.to_string e)
            (Printexc.get_backtrace ())
        in
        failwith msg
    )
    tests

let _ =
  Printexc.record_backtrace true;
  test_runner tests;
  print_endline "\nSUCCESS"
