BeginPackage["AntonAntonov`PaLMLink`EmbedText`"];

Begin["`Private`"];

Needs["AntonAntonov`PaLMLink`"];
Needs["AntonAntonov`PaLMLink`Constants`"];
Needs["AntonAntonov`PaLMLink`Request`"];


(*=========================================================*)
(* PaLM EmbedText                                          *)
(*=========================================================*)

Options[PaLMEmbedText] = {
  "APIKey" :> $PaLMAPIKey,
  "User" :> $PaLMAPIUser,
  "Model" -> "embedding-gecko-001"
};

SetAttributes[PaLMEmbedText, Listable];

PaLMEmbedText[str_String, propSpec_, opts : OptionsPattern[]] :=
    ConformEmbedding[
      PaLMRequest[
        "v1beta2/models/" <> OptionValue[PaLMEmbedText, "Model"] <> ":embedText",
        Select[
          <|
            "text" -> str
          |>,
          # =!= Automatic&
        ],
        {opts},
        PaLMEmbedText
      ],
      propSpec
    ];

PaLMEmbedText[str_String, opts : OptionsPattern[]] :=
    PaLMEmbedText[str, "Embedding", opts];

ConformEmbedding[data_, propSpec_] :=
    Enclose[GetResponseDataProperty[Confirm@ResponseData[data], propSpec], "InheritedFailure"];

ConformEmbedding[fail_?FailureQ, propSpec_] := fail;

ResponseData[
  KeyValuePattern[
    "embedding" ->
        KeyValuePattern[{
          "value" -> embedding : {_?NumberQ..}
        }]
  ]
] :=
    <|
      "Embedding" -> embedding
    |>;

ResponseData[data_] := InvalidEmbeddingResponse[data];

GetResponseDataProperty[respData_, "Embedding"] := respData["Embedding"];

GetResponseDataProperty[respData_, props_List] := GetResponseDataProperty[respData, #] & /@ props;

GetResponseDataProperty[respData_, propSpec_] :=
    (
      Message[PaLMEmbedText::invProp, propSpec];
      Failure["InvalidProperty", <|
        "MessageTemplate" :> PaLMEmbedText::invProp,
        "MessageParameters" -> {propSpec},
        "Property" -> propSpec,
        "ResponseData" -> respData
      |>]
    );

InvalidEmbeddingResponse[data_] :=
    (
      Message[PaLMEmbedText::invPaLMEmbedTextResponse, data];
      Failure["InvalidPaLMEmbedTextResponse", <|
        "MessageTemplate" :> PaLMEmbedText::invPaLMEmbedTextResponse,
        "MessageParameters" -> {data},
        "Response" -> data
      |>]
    );

End[];
EndPackage[];
