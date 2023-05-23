BeginPackage["AntonAntonov`PaLMLink`Models`"];

Begin["`Private`"];

Needs["AntonAntonov`PaLMLink`"];
Needs["AntonAntonov`PaLMLink`Constants`"];
Needs["AntonAntonov`PaLMLink`Request`"];

Options[PaLMModels] = {
	"APIKey"  :> $PaLMAPIKey,
	"User" :> $PaLMAPIUser
};

PaLMModels[opts:OptionsPattern[]] :=
	ConformModels @ PaLMRequest[
		{"v1beta2", "models"},
		None,
		{opts},
		PaLMModels
	];

ConformModels[data_] :=
	Enclose[
		Module[{list},
			list = Confirm[data["models"]];
			Lookup[#, "name", Message[PaLMModels::invPaLMModelResponse, #];Nothing] &/@ list
		],
		(
			Message[PaLMModels::invPaLMModelResponse, data];
			Failure["InvalidPaLMModelResponse", <|
				"MessageTemplate" :> PaLMModels::invPaLMModelResponse,
				"MessageParameters" -> {data},
				"Response" -> data,
				"ConfirmationFailure" -> #
			|>]
		)&
	];

ConformModels[fail_?FailureQ] := fail;

End[];
EndPackage[];
