# twilio-ocaml

OCaml bindings for [Twilio API](http://www.twilio.com/docs/api).

## Dependencies (required)

* [atdgen](http://github.com/MyLifeLabs/atdgen.git)
* [atd](http://github.com/MyLifeLabs/atd.git)
* [easy-format](http://martin.jambon.free.fr/easy-format.html)
* [menhir](http://pauillac.inria.fr/~fpottier/menhir/)
* [cppo](http://martin.jambon.free.fr/cppo.html)
* [biniou](http://martin.jambon.free.fr/biniou.html)
* [yojson](http://martin.jambon.free.fr/yojson.html)
* [ocaml-ssl](http://sourceforge.net/projects/savonet/files/ocaml-ssl/)
* [ocamlnet]

You can use [bootstrap.sh](https://github.com/mrnumber/twilio-ocaml/blob/master/bootstrap.sh) to download and install the above.

## Dependencies (optional)

* [lwt](http://ocsigen.org/lwt/install)

You may optionally build an Lwt version of the Twilio client.

## Quick start

    make
    make install

If Lwt is installed, you may also run:

    make lwt

## Module descriptions

`Twilio_rest_request` -- generates the URLs and POST data for the API
`Twilio_rest` -- binds together the request, HTTP client, and atd generated response parsers
`Twilio_rest_convenience`  -- convenient module for making synchronous API requests
`Twilio_rest_printer` -- convenient module for printing API requests (no networking)

Additionally, the twilio-lwt package provices

`Twilio_rest_lwt` -- convenient module for making asynchronous API requests using Lwt

## Caveats

* Currently, only the [REST API](http://www.twilio.com/docs/api/rest) is provided
* This is still a preview release, not all API bindings are present or correct.  Please submit issues or pull requests.

## Example

```ocaml
# module T = Twilio_rest_convenience.Make(struct
    let account_sid = "FOO"
    let auth_token = "BAR"
  end);;
# T.Sms.Messages.get ();;
# T.Sms.Messages.post
  ~from_number:"6505551212"
  ~to_number:"4155551212"
  ~body:"Setting up my ocaml twilio bindings";;
```

## Known Issues

* For SSL requests with basic authorization -- i.e. how these bindings make requests -- `Http_client` requires that a `GET` be made before a `POST` will succeed.