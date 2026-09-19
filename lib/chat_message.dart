// One message in the chat.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  final String text;

  // true = written by the person, false = written by the AI.
  final bool isUser;

  // true = this is an error message shown in the chat (not real AI output).
  final bool isError;
}
