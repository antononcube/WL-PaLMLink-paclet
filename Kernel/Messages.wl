BeginPackage["AntonAntonov`PaLMLink`Messages`"];

Begin["`Private`"];

Needs["AntonAntonov`PaLMLink`"];
Needs["AntonAntonov`PaLMLink`Request`"];


PaLMFileDelete::palmResponseFailureCode =
PaLMFileInformation::palmResponseFailureCode =
PaLMModels::palmResponseFailureCode =
PaLMRequest::palmResponseFailureCode =
PaLMGenerateText::palmResponseFailureCode =
PaLMGenerateMessage::palmResponseFailureCode =
PaLMGenerateImage::palmResponseFailureCode =
PaLMTranscribeAudio::palmResponseFailureCode =
PaLMTranslateAudio::palmResponseFailureCode =
PaLMEmbedText::palmResponseFailureCode =
PaLMFileUpload::palmResponseFailureCode = "Request to the PaLM API failed with status code `1`.";

PaLMFileDelete::palmResponseFailureCode =
PaLMFileInformation::palmResponseFailureMessage =
PaLMModels::palmResponseFailureMessage =
PaLMRequest::palmResponseFailureMessage =
PaLMGenerateText::palmResponseFailureMessage =
PaLMGenerateMessage::palmResponseFailureMessage =
PaLMGenerateImage::palmResponseFailureMessage =
PaLMTranscribeAudio::palmResponseFailureMessage =
PaLMTranslateAudio::palmResponseFailureMessage =
PaLMEmbedText::palmResponseFailureMessage =
PaLMFileUpload::palmResponseFailureMessage = "Request to the PaLM API failed with message: `1`.";

PaLMFileDelete::palmResponseFailureCode =
PaLMFileInformation::invalidPaLMAPIKey =
PaLMModels::invalidPaLMAPIKey =
PaLMRequest::invalidPaLMAPIKey =
PaLMGenerateText::invalidPaLMAPIKey =
PaLMGenerateMessage::invalidPaLMAPIKey =
PaLMGenerateImage::invalidPaLMAPIKey =
PaLMTranscribeAudio::invalidPaLMAPIKey =
PaLMTranslateAudio::invalidPaLMAPIKey =
PaLMEmbedText::invalidPaLMAPIKey =
PaLMFileUpload::invalidPaLMAPIKey = "`1` is not a valid PaLM API key. Consider setting the PaLMKey option or the $PaLMKey constant to a string containing a valid PaLM API key.";

PaLMModels::invPaLMModelResponse = "The PaLM API returned invalid model specification `1`.";

PaLMGenerateText::invPaLMGenerateTextResponse = "The PaLM API returned invalid completion specification `1`.";
PaLMGenerateText::invPromptSpec = "Invalid prompt specification `1`. Expected a string or a pair of strings.";
PaLMGenerateText::invProbResponse = "Request to the PaLM API returned an invalid report of token probabilities `1`.";

PaLMGenerateMessage::invPaLMGenerateMessageResponse = "The PaLM API returned invalid completion specification `1`.";
PaLMGenerateMessage::invPromptSpec = "Invalid prompt specification `1`. Expected an chat message or a list of chat messages.";
PaLMGenerateMessage::invUsageResponse = "Request to the PaLM API returned an invalid report of its usage: `1`.";

PaLMGenerateMessage::invUsageResponse =
PaLMGenerateText::invUsageResponse = "Request to the PaLM API returned an invalid report of its usage: `1`.";

PaLMEmbedText::invPaLMEmbedTextResponse = "The PaLM API returned invalid embedding specification `1`.";
PaLMEmbedText::invProp = "`1` is not a known property for PaLMEmbedText.";
PaLMEmbedText::invUsageResponse = "Request to the PaLM API returned an invalid report of its usage: `1`.";

PaLMFile::invPaLMFile = "Invalid PaLMFile object with data `1`.";


End[];
EndPackage[];
