BeginPackage["AntonAntonov`PaLMLink`Constants`"];

Begin["`Private`"];

Needs["AntonAntonov`PaLMLink`"];

(*
	PaLM examples show API keys are loaded from the PALM_API_KEY environment variable by default:
	https://developers.generativeai.google/api/rest/generativelanguage

	SystemCredential is more secure, so that is the top-priority option here. (Read that in "ChristopherWolfram/OpenAILink".)
*)

$PaLMAPIKey:=
	With[{key = GetAPIKey[]},
		If[!MissingQ[key], $PaLMAPIKey = key, key]
	];

GetAPIKey[] :=
	Catch@Module[{key},
		key = SystemCredential["PaLMAPIKey"];
		If[!MissingQ[key], Throw[key]];

		key = SystemCredential["PALM_API_KEY"];
		If[!MissingQ[key], Throw[key]];

		key = Environment["PALM_API_KEY"];
		Replace[key, $Failed -> Missing["invalidPaLMAPIKey"]]
	];


(* Maybe in the future PaLM API is going to have user parameter. *)
$PaLMAPIUser = None;

End[];
EndPackage[];
