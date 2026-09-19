// ---------------------------------------------------------------
//  All the settings you may want to change live in this file.
// ---------------------------------------------------------------

// 1) Paste your Gemini API key here.
//    Get a free key at https://aistudio.google.com  ->  "Get API key".
//
//    DEMO ONLY: a key stored in app code can be extracted by anyone who
//    has the app. Never publish this app or upload this file with a real key.
const String geminiApiKey = 'AQ.Ab8RN6LeNXxHHIrnUJlUlmw77GET8gjZxOs2J69jvjDyPCMdLA';

// 2) Which Gemini model to use. If you get a "model not found" error,
//    look up the current model names at https://ai.google.dev/gemini-api/docs/models
//    (for example 'gemini-2.5-flash' also works while it is still available).
const String geminiModel = 'gemini-3.5-flash';

// 3) Tells the AI how to behave. Try changing it!
const String systemPrompt =
    'You are a friendly AI assistant inside a Flutter demo app for beginners. '
    'Keep answers short and clear. '
    'Reply in plain text without Markdown formatting (no asterisks, no # headings).';

// A simple class that describes one allowed user.
class DemoUser {
  const DemoUser({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

// 4) The ONLY three accounts that can log in.
//    (Static demo data. A real app would check a server instead.)
const List<DemoUser> allowedUsers = [
  DemoUser(name: 'Alice', email: 'alice@demo.com', password: 'Alice@123'),
  DemoUser(name: 'Bob', email: 'bob@demo.com', password: 'Bob@123'),
  DemoUser(name: 'Carol', email: 'carol@demo.com', password: 'Carol@123'),
];
