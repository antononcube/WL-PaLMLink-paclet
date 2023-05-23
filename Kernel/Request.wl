BeginPackage["AntonAntonov`PaLMLink`Request`"];

PaLMRequest::usage = "Makes a request to the PaLM API at the specified path and with the specified body.";

ConformResponse::usage = "ConformResponse[head, resp] \
takes an HTTPResponse and returns the contained JSON data. Returns a Failure if the request failed. \
The first argument (head) is used for messages.";

Begin["`Private`"];

Needs["AntonAntonov`PaLMLink`"];
Needs["AntonAntonov`PaLMLink`Constants`"];

(*=========================================================*)
(* PaLMRequest                                             *)
(*=========================================================*)

(*
	PaLMRequest[path, body, opts, head]
		makes a request to the PaLM API at the specified path and with the specified body.

		path: a list of strings in the format expected by URLRead.

		body: an expression which is automatically converted to JSON. If the body is None, no body will be specified.

		opts: a list containing the options passed to the higher-level request function.

		head: the head of the higher-level request function for use in option resolution and messages.
*)

Options[PaLMRequest] = {
	"APIKey"  :> $PaLMAPIKey,
	"User" :> $PaLMAPIUser
};

PaLMRequest[path_, body:_Association|None:None, opts_List:{}, head_:PaLMRequest] :=
	Enclose[Module[{apiKey, user, bodyRule, resp, multipartQ = False},

		apiKey = OptionValue[head, opts, "APIKey"];
		user = OptionValue[head, opts, "User"];

		ConfirmBy[apiKey, StringQ,
			Message[head::invalidPaLMAPIKey, apiKey];
			Failure["InvalidPaLMKey", <|
				"MessageTemplate" :> head::invalidPaLMAPIKey,
				"MessageParameters" -> {apiKey}
			|>]
		];

		bodyRule =
			If[body === None,
				Nothing,
				"Body" -> Confirm[
					If[	multipartQ,
						Identity,
						ExportByteArray[#, "JSON"] &
					] @ If[user =!= None, Append[body, "user" -> user], body],
					$Failed
				]
			];

		resp = URLRead[
			<|
				"Scheme" -> "https",
				"Domain" -> "generativelanguage.googleapis.com",
				"Query" -> <| "key" -> apiKey |>,
				"Method" -> If[body === None, "GET", "POST"],
				"ContentType" -> If[multipartQ, "multipart/form-data", "application/json"],
				"Path" -> path,
				bodyRule
			|>
		];

		ConformResponse[head, resp]

	], "InheritedFailure"];


ConformResponse[head_, resp_] :=
	Catch@Module[{statusCode, body},

		statusCode = resp["StatusCode"];
		body = ImportByteArray[resp["BodyByteArray"], "RawJSON"];

		If[FailureQ[body],
			Throw@ResponseFailureCode[head, resp, statusCode]
		];

		Which[

			KeyExistsQ[body,"error"],
				If[KeyExistsQ[body["error"],"message"],
					Throw@ResponseFailureMessage[head, resp, body["error"]["message"]],
					Throw@ResponseFailureCode[head, resp, statusCode]
				],

			statusCode =!= 200,
				Throw@ResponseFailureCode[head, resp, statusCode],

			True,
				body

		]
		
	];


ResponseFailureCode[head_, resp_, code_] :=
	(
		Message[head::openAIResponseFailureCode, code];
		Failure["PaLMResponseFailure", <|
			"MessageTemplate" :> head::openAIResponseFailureCode,
			"MessageParameters" -> {code},
			"HTTPResponse" -> resp
		|>]
	);

ResponseFailureMessage[head_, resp_, message_] :=
	(
		Message[head::openAIResponseFailureMessage, message];
		Failure["PaLMResponseFailure", <|
			"MessageTemplate" :> head::openAIResponseFailureMessage,
			"MessageParameters" -> {message},
			"HTTPResponse" -> resp
		|>]
	);

End[];
EndPackage[];
