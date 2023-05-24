BeginPackage["AntonAntonov`PaLMLink`GenerateMessage`"];

Begin["`Private`"];

Needs["AntonAntonov`PaLMLink`"];
Needs["AntonAntonov`PaLMLink`Constants`"];
Needs["AntonAntonov`PaLMLink`Request`"];

CleaAll[PaLMGeneratedMessageObject];

(*=========================================================*)
(* PaLM GenerateMessage                                    *)
(*=========================================================*)


Options[PaLMGenerateMessage] = {
  "APIKey" :> $PaLMAPIKey,
  "User" :> $PaLMAPIUser,
  "Model" -> Automatic,
  "Temperature" -> Automatic,
  "TopProbability" -> Automatic,
  "TopTokensCount" -> Automatic
};

PaLMGenerateMessage[args___] :=
    Enclose[
      iPaLMGenerateMessage@Confirm@ArgumentsOptions[PaLMGenerateMessage[args], {1, 3}],
      "InheritedFailure"
    ];


(* Text generation *)
iPaLMGenerateMessage[{{prompt_String, propSpec_, n_}, opts_}] :=
    iPaLMGenerateMessage[{{{<|"content" -> prompt|>}, propSpec, n}, opts}];

iPaLMGenerateMessage[{{prompt : {_String..}, propSpec_, n_}, opts_}] :=
    iPaLMGenerateMessage[{{<|"content" -> #|> & /@ prompt, propSpec, n}, opts}];

iPaLMGenerateMessage[{{prompt : {_Association..}, propSpec_, n_}, opts_}] :=
    Module[{rawResponse},
      rawResponse =
          PaLMRequest[
            "v1beta2/models/" <> Replace[OptionValue[PaLMGenerateMessage, opts, "Model"], Automatic -> "chat-bison-001"] <> ":generateMessage",
            Select[
              <|
                "prompt" -> <| "messages" -> prompt |>,
                "candidateCount" -> n,
                "temperature" -> OptionValue[PaLMGenerateMessage, opts, "Temperature"],
                "topP" -> OptionValue[PaLMGenerateMessage, opts, "TopProbability"],
                "topK" -> OptionValue[PaLMGenerateMessage, opts, "TopTokensCount"]
              |>,
              !MemberQ[{Automatic, None}, #]&
            ],
            {opts},
            PaLMGenerateMessage
          ];

      ConformGeneration[rawResponse, prompt, propSpec]
    ];

iPaLMGenerateMessage[{{promptSpec_, propSpec_, n_}, opts_}] :=
    (
      Message[PaLMGenerateMessage::invPromptSpec, promptSpec];
      Failure["InvalidPromptSpecification", <|
        "MessageTemplate" :> PaLMGenerateMessage::invPromptSpec,
        "MessageParameters" -> {promptSpec},
        "PromptSpecification" -> promptSpec
      |>]
    );

iPaLMGenerateMessage[{{promptSpec_, propSpec_}, opts_}] :=
    Replace[iPaLMGenerateMessage[{{promptSpec, propSpec, 1}, opts}], {res_} :> res];

iPaLMGenerateMessage[{{promptSpec_}, opts_}] :=
    iPaLMGenerateMessage[{{promptSpec, "Content"}, opts}];

(*=========================================================*)
(* Conforming                                              *)
(*=========================================================*)

Clear[ConformGeneration];

ConformGeneration[asc_?AssociationQ, prompt_, propSpec_] :=
    ConformGeneration[asc["candidates"], prompt, propSpec];

ConformGeneration[asc : {_?AssociationQ..}, prompt_, propSpec_] :=
    GetChoiceProperty[ConformCompletionChoice[#, prompt], propSpec] & /@ asc;

ConformGeneration[fail_?FailureQ, prompt_, propSpec_] := fail;

ConformGeneration[data_, prompt_, propSpec_] := CompletionResponseError[data];

GetChoiceProperty[choice_PaLMGeneratedMessageObject, All] := choice;

GetChoiceProperty[choice_PaLMGeneratedMessageObject, props_List] := choice /@ props;

GetChoiceProperty[choice_PaLMGeneratedMessageObject, prop_] := choice[prop];

GetChoiceProperty[choice_, propSpec_] := choice;

ClearAll[ConformCompletionChoice];

ConformCompletionChoice[
  choice : KeyValuePattern[{ "content" -> text_, "author" -> author_, "citationMetadata" -> citation_}],
  prompt_] :=
PaLMGeneratedMessageObject[<|
  "Prompt" -> prompt,
  "Content" -> text,
  "Author" -> author,
  "CitationMetadata" -> citation|>];

ConformCompletionChoice[
  choice : KeyValuePattern[{ "content" -> text_, "author" -> author_}],
  prompt_] := PaLMGeneratedMessageObject[<|
  "Prompt" -> prompt,
  "Content" -> text,
  "Author" -> author|>];

ConformCompletionChoice[data_, prompt_] := CompletionResponseError[data];


CompletionResponseError[data_] :=
    (
      Message[PaLMGenerateMessage::invPaLMGenerateMessageResponse, data];
      Failure["InvalidPaLMGenerateMessageResponse", <|
        "MessageTemplate" :> PaLMGenerateMessage::invPaLMGenerateMessageResponse,
        "MessageParameters" -> {data},
        "Response" -> data
      |>]
    );


(*=========================================================*)
(* PaLM GenerateTextObject                                 *)
(*=========================================================*)


(***** Verifier *****)

HoldPattern[PaLMGeneratedMessageObject][data : Except[KeyValuePattern[{
  "Prompt" -> _,
  "Content" -> _,
  "Author" -> _
}]]] :=
    (
      Message[PaLMGeneratedMessageObject::invPaLMGeneratedMessageObject, data];
      Failure["InvalidPaLMGeneratedMessageObject", <|
        "MessageTemplate" :> PaLMGeneratedMessageObject::invPaLMGeneratedMessageObject,
        "MessageParameters" -> {data},
        "Data" -> data
      |>]
    );


(***** Accessors *****)

completion_PaLMGeneratedMessageObject[All] := AssociationMap[completion[#]&, completion["Properties"]];

completion_PaLMGeneratedMessageObject["Author"] := First[completion]["Author"];
completion_PaLMGeneratedMessageObject["CitationMetadata"] := First[completion]["CitationMetadata"];
completion_PaLMGeneratedMessageObject["Content"] := First[completion]["Content"];
completion_PaLMGeneratedMessageObject["Prompt"] := First[completion]["Prompt"];

completion_PaLMGeneratedMessageObject["Properties"] :=
    {
      "Author",
      "Content",
      "Prompt",
      "CitationMetadata"
    };

completion_PaLMGeneratedMessageObject[prop_] :=
    (
      Message[PaLMGeneratedMessageObject::invProp, prop];
      Failure["InvalidProperty", <|
        "MessageTemplate" :> PaLMGeneratedMessageObject::invProp,
        "MessageParameters" -> {prop},
        "Property" -> prop,
        "Content" -> completion
      |>]
    );


(***** Summary Box *****)

PaLMGeneratedMessageObject /: MakeBoxes[completion_PaLMGeneratedMessageObject, form : StandardForm] := (
  BoxForm`ArrangeSummaryBox[
    PaLMGeneratedMessageObject,
    completion,
    None,
    (*the next argument is the always visible properties*)
    {
      BoxForm`SummaryItem@{"Author: ", completion["Author"]},
      BoxForm`SummaryItem@{"Content: ", completion["Content"]}
    },
    {
      BoxForm`SummaryItem@{"Prompt: ", completion["Prompt"]},
      If[KeyExistsQ[First[completion], "CitationMetadata"],
        BoxForm`SummaryItem@{"CitationMetadata: ", completion["CitationMetadata"]},
        Nothing
      ]
    },
    form
  ]);



End[];
EndPackage[];
