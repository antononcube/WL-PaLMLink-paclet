
BeginPackage["AntonAntonov`PaLMLink`"];

$PaLMAPIKey::usage = "PaLM API key.";
$PaLMAPIUser::usage = "PaLM API user.";

PaLMModels::usage = "Returns available PaLM models.";
PaLMGenerateText::usage = "Generates text.";
PaLMGenerateMessage::usage = "Generates message.";
PaLMEmbedText::usage = "PaLMEmbedText[str] gets a vector embedding of the text str.";
PaLMGeneratedTextObject::usage = "Object representing generated text.";
PaLMGeneratedMessageObject::usage = "Object representing generated message.";

Begin["`Private`"];

$PaLMAPIUser = None;

Needs["AntonAntonov`PaLMLink`Constants`"];
Needs["AntonAntonov`PaLMLink`Request`"];
Needs["AntonAntonov`PaLMLink`Models`"];
Needs["AntonAntonov`PaLMLink`GenerateText`"];
Needs["AntonAntonov`PaLMLink`GenerateMessage`"];
Needs["AntonAntonov`PaLMLink`EmbedText`"];
Needs["AntonAntonov`PaLMLink`Messages`"];

End[];
EndPackage[];