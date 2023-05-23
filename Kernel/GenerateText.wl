BeginPackage["AntonAntonov`PaLMLink`GenerateText`"];

Begin["`Private`"];

Needs["AntonAntonov`PaLMLink`"];
Needs["AntonAntonov`PaLMLink`Constants`"];
Needs["AntonAntonov`PaLMLink`Request`"];

CleaAll[PaLMGeneratedTextObject];

(*=========================================================*)
(* PaLM GenerateText                                       *)
(*=========================================================*)

(*
	PaLMGenerateText[prompt]
		completes the string starting with the prompt.

	PaLMGenerateText[promptSpec, propSpec]
		returns the property or list of properties specified by propSpec.

	PaLMGenerateText[promptSpec, All]
		returns a PaLMGeneratedTextObject containing all results of the completion.

	PaLMGenerateText[promptSpec, propSpec, n]
		generates n completions.
*)

Options[PaLMGenerateText] = {
  "APIKey" :> $PaLMAPIKey,
  "User" :> $PaLMAPIUser,
  "Model" -> Automatic,
  "Temperature" -> Automatic,
  "TopProbability" -> Automatic,
  "TopTokensCount" -> Automatic,
  "MaxOutputTokens" -> Automatic,
  "SafetySettings" -> Automatic,
  "StopSequences" -> Automatic
};

PaLMGenerateText[args___] :=
    Enclose[
      iPaLMGenerateText@Confirm@ArgumentsOptions[PaLMGenerateText[args], {1, 3}],
      "InheritedFailure"
    ];


(* Text generation *)
iPaLMGenerateText[{{prompt_String, propSpec_, n_}, opts_}] :=
    Module[{rawResponse},
      rawResponse =
          PaLMRequest[
            "v1beta2/models/" <> Replace[OptionValue[PaLMGenerateText, opts, "Model"], Automatic -> "text-bison-001"] <> ":generateText",
            Select[
              <|
                "prompt" -> <| "text" -> prompt |>,
                "candidateCount" -> n,
                "temperature" -> OptionValue[PaLMGenerateText, opts, "Temperature"],
                "topP" -> OptionValue[PaLMGenerateText, opts, "TopProbability"],
                "topK" -> OptionValue[PaLMGenerateText, opts, "TopTokensCount"],
                "maxOutputTokens" -> OptionValue[PaLMGenerateText, opts, "MaxOutputTokens"],
                "stopSequences" -> OptionValue[PaLMGenerateText, opts, "StopSequences"]
              |>,
              !MemberQ[{Automatic, None}, #]&
            ],
            {opts},
            PaLMGenerateText
          ];

      ConformGeneration[rawResponse, prompt, propSpec]
    ];

iPaLMGenerateText[{{promptSpec_, propSpec_, n_}, opts_}] :=
    (
      Message[PaLMGenerateText::invPromptSpec, promptSpec];
      Failure["InvalidPromptSpecification", <|
        "MessageTemplate" :> PaLMGenerateText::invPromptSpec,
        "MessageParameters" -> {promptSpec},
        "PromptSpecification" -> promptSpec
      |>]
    );

iPaLMGenerateText[{{promptSpec_, propSpec_}, opts_}] :=
    Replace[iPaLMGenerateText[{{promptSpec, propSpec, 1}, opts}], {res_} :> res];

iPaLMGenerateText[{{promptSpec_}, opts_}] :=
    iPaLMGenerateText[{{promptSpec, "Generated"}, opts}];

(*=========================================================*)
(* Conforming                                              *)
(*=========================================================*)

Clear[ConformGeneration];

(*ConformGeneration[asc_?AssociationQ] := asc["candidates"]["output"];*)

ConformGeneration[asc_?AssociationQ, prompt_, propSpec_] :=
    (
    GetChoiceProperty[ConformCompletionChoice[#, prompt], propSpec] & /@ asc["candidates"]
    ) /; KeyExistsQ[asc, "candidates"];

ConformGeneration[fail_?FailureQ, prompt_, propSpec_] := fail;

ConformGeneration[data_, prompt_, propSpec_] := CompletionResponseError[data];


GetChoiceProperty[choice_PaLMGeneratedTextObject, All] := choice;

GetChoiceProperty[choice_PaLMGeneratedTextObject, props_List] := choice /@ props;

GetChoiceProperty[choice_PaLMGeneratedTextObject, prop_] := choice[prop];

GetChoiceProperty[choice_, propSpec_] := choice;


ConformCompletionChoice[
  choice : KeyValuePattern[{ "output" -> text_, "safetyRatings" -> safetyRatings_List}],
  prompt_] :=
    PaLMGeneratedTextObject[<|
      "Prompt" -> prompt,
      "Generated" -> text,
      "SafetyRatings" -> safetyRatings
    |>];

ConformCompletionChoice[data_, prompt_] := CompletionResponseError[data];


CompletionResponseError[data_] :=
    (
      Message[PaLMGenerateText::invPaLMGenerateTextResponse, data];
      Failure["InvalidPaLMGenerateTextResponse", <|
        "MessageTemplate" :> PaLMGenerateText::invPaLMGenerateTextResponse,
        "MessageParameters" -> {data},
        "Response" -> data
      |>]
    );


(*=========================================================*)
(* PaLM GenerateTextObject                                 *)
(*=========================================================*)


(***** Verifier *****)

HoldPattern[PaLMGeneratedTextObject][data : Except[KeyValuePattern[{
  "Prompt" -> _String,
  "Generated" -> _String,
  "SafetyRatings" -> _
}]]] :=
    (
      Message[PaLMGeneratedTextObject::invPaLMGeneratedTextObject, data];
      Failure["InvalidPaLMGeneratedTextObject", <|
        "MessageTemplate" :> PaLMGeneratedTextObject::invPaLMGeneratedTextObject,
        "MessageParameters" -> {data},
        "Data" -> data
      |>]
    );


(***** Accessors *****)

completion_PaLMGeneratedTextObject[All] := AssociationMap[completion[#]&, completion["Properties"]];

completion_PaLMGeneratedTextObject["Candidates"] := First[completion]["Candidates"];
completion_PaLMGeneratedTextObject["Filters"] := First[completion]["Filters"];
completion_PaLMGeneratedTextObject["Generated"] := First[completion]["Generated"];
completion_PaLMGeneratedTextObject["Prompt"] := First[completion]["Prompt"];
completion_PaLMGeneratedTextObject["SafetyFeedback"] := First[completion]["SafetyFeedback"];
completion_PaLMGeneratedTextObject["SafetyRatings"] := First[completion]["SafetyRatings"];

completion_PaLMGeneratedTextObject["Properties"] :=
    {
      "Prompt",
      "Generated",
      "SafetyRatings"
    };

completion_PaLMGeneratedTextObject[prop_] :=
    (
      Message[PaLMGeneratedTextObject::invProp, prop];
      Failure["InvalidProperty", <|
        "MessageTemplate" :> PaLMGeneratedTextObject::invProp,
        "MessageParameters" -> {prop},
        "Property" -> prop,
        "Generated" -> completion
      |>]
    );


(***** Summary Box *****)

PaLMGeneratedTextObject /: MakeBoxes[completion_PaLMGeneratedTextObject, form : StandardForm] :=(
    BoxForm`ArrangeSummaryBox[
      PaLMGeneratedTextObject,
      completion,
      None,
      (*the next argument is the always visible properties*)
      {
        BoxForm`SummaryItem@{"Prompt: ", completion["Prompt"]},
        BoxForm`SummaryItem@{"Generated: ", completion["Generated"]}
      },
      {
        BoxForm`SummaryItem@{"SafetyRatings: ", completion["SafetyRatings"]}
      },
      form
    ]);



End[];
EndPackage[];
