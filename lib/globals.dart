library multicultproj.globals;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Language settings

List<Map<String, String>> languages = [
  {'name': 'English', 'flag': '🇺🇸'},
  {'name': 'Vietnamese', 'flag': '🇻🇳'},
  {'name': 'Español', 'flag': '🇪🇸'},
  {'name': 'Français', 'flag': '🇫🇷'},
  {'name': '日本語', 'flag': '🇯🇵'},
];

int _selectedIndex = 0;
String _userEmail = 'user@example.com';
String _userName = 'Jane Doe';
String _userBirthYear = '2000';

int get selectedIndex => _selectedIndex;
set selectedIndex(int value) {
  _selectedIndex = value;
  _saveInt('selectedIndex', value);
}

String get userEmail => _userEmail;
set userEmail(String value) {
  _userEmail = value;
  _saveString('userEmail', value);
}

String get userName => _userName;
set userName(String value) {
  _userName = value;
  _saveString('userName', value);
}

String get userBirthYear => _userBirthYear;
set userBirthYear(String value) {
  _userBirthYear = value;
  _saveString('userBirthYear', value);
}

class WordTranslations {
  final String eng;
  final String vie;
  final String esp;
  final String fra;
  final String jpn;

  const WordTranslations({
    required this.eng,
    required this.vie,
    required this.esp,
    required this.fra,
    required this.jpn,
  });
}

Map<String, WordTranslations> wordDictionary = {
  '사과': const WordTranslations(
    eng: 'apple',
    vie: 'táo',
    esp: 'manzana',
    fra: 'pomme',
    jpn: 'りんご',
  ),
  '물': const WordTranslations(
    eng: 'water',
    vie: 'nước',
    esp: 'agua',
    fra: 'eau',
    jpn: 'みず',
  ),
  '학교': const WordTranslations(
    eng: 'school',
    vie: 'trường học',
    esp: 'escuela',
    fra: 'école',
    jpn: 'がっこう',
  ),
  '책': const WordTranslations(
    eng: 'book',
    vie: 'sách',
    esp: 'libro',
    fra: 'livre',
    jpn: 'ほん',
  ),
  '고양이': const WordTranslations(
    eng: 'cat',
    vie: 'mèo',
    esp: 'gato',
    fra: 'chat',
    jpn: 'ねこ',
  ),
};

// Chat functionality
class ChatMessage {
  final String text;
  final bool isUser;
  
  ChatMessage({required this.text, required this.isUser});

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isUser: json['isUser'],
  );
}

List<ChatMessage> _chatMessages = [
  ChatMessage(
    text: '안녕하세요! 무엇을 도와드릴까요?',
    isUser: false,
  ),
  ChatMessage(
    text: '두통이 자주 있는데, 원인이 뭘까요?',
    isUser: true,
  ),
  ChatMessage(
    text: '두통은 다양한 원인이 있을 수 있습니다. 최근에 스트레스를 많이 받으셨나요?',
    isUser: false,
  ),
  ChatMessage(
    text: '네, 요즘 공부 때문에 스트레스가 많아요.',
    isUser: true,
  ),
  ChatMessage(
    text: '스트레스가 두통의 원인일 수 있습니다. 충분한 휴식과 수분 섭취를 권장합니다.',
    isUser: false,
  ),
];

List<ChatMessage> get chatMessages => _chatMessages;
set chatMessages(List<ChatMessage> value) {
  _chatMessages = value;
  _saveChatMessages();
}

void addChatMessage(ChatMessage msg) {
  _chatMessages.add(msg);
  _saveChatMessages();
}

void clearChatMessages() {
  _chatMessages.clear();
  _saveChatMessages();
}

// Quiz functionality
enum QuizType { mcq, typing, matching, mixed }

class MCQQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const MCQQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class TypingQuestion {
  final String question;
  final List<String> acceptedAnswers;
  final String explanation;

  const TypingQuestion({
    required this.question,
    required this.acceptedAnswers,
    required this.explanation,
  });
}

class MatchingQuestion {
  final String title;
  final Map<String, String> pairs;
  final String explanation;

  const MatchingQuestion({
    required this.title,
    required this.pairs,
    required this.explanation,
  });
}

// Sample quiz questions
List<MCQQuestion> sampleMCQQuestions = [
  MCQQuestion(
    question: "What does '물' mean in English?",
    options: ["Fire", "Water", "Earth", "Air"],
    correctIndex: 1,
    explanation: "물 (mul) means water in Korean.",
  ),
  MCQQuestion(
    question: "Which language uses '猫' for cat?",
    options: ["Korean", "Vietnamese", "Japanese", "Spanish"],
    correctIndex: 2,
    explanation: "猫 (neko) is the Japanese character for cat.",
  ),
  MCQQuestion(
    question: "What is 'book' in Spanish?",
    options: ["libro", "livro", "livre", "kitab"],
    correctIndex: 0,
    explanation: "Libro is the Spanish word for book.",
  ),
  MCQQuestion(
    question: "What does '학교' mean in English?",
    options: ["House", "School", "Store", "Park"],
    correctIndex: 1,
    explanation: "학교 (hakkyo) means school in Korean.",
  ),
  MCQQuestion(
    question: "Which is the correct French word for 'cat'?",
    options: ["chien", "chat", "cheval", "cochon"],
    correctIndex: 1,
    explanation: "Chat is the French word for cat.",
  ),
  MCQQuestion(
    question: "What does 'água' mean in Portuguese?",
    options: ["Fire", "Earth", "Water", "Wind"],
    correctIndex: 2,
    explanation: "Água means water in Portuguese.",
  ),
  MCQQuestion(
    question: "Which flag represents Japan?",
    options: ["🇰🇷", "🇨🇳", "🇯🇵", "🇹🇭"],
    correctIndex: 2,
    explanation: "🇯🇵 is the flag of Japan.",
  ),
  MCQQuestion(
    question: "What is 'hello' in Spanish?",
    options: ["hola", "bonjour", "ciao", "guten tag"],
    correctIndex: 0,
    explanation: "Hola means hello in Spanish.",
  ),
  MCQQuestion(
    question: "Which language family does Korean belong to?",
    options: ["Indo-European", "Sino-Tibetan", "Koreanic", "Japonic"],
    correctIndex: 2,
    explanation: "Korean belongs to the Koreanic language family.",
  ),
  MCQQuestion(
    question: "What does 'merci' mean in English?",
    options: ["Hello", "Goodbye", "Please", "Thank you"],
    correctIndex: 3,
    explanation: "Merci means thank you in French.",
  ),
];

List<TypingQuestion> sampleTypingQuestions = [
  TypingQuestion(
    question: "Type the English translation of '사과':",
    acceptedAnswers: ["apple", "apples"],
    explanation: "사과 (sagwa) means apple in Korean.",
  ),
  TypingQuestion(
    question: "What is the Vietnamese word for 'school'?",
    acceptedAnswers: ["trường học", "truong hoc"],
    explanation: "Trường học is Vietnamese for school.",
  ),
  TypingQuestion(
    question: "Type the French word for 'water':",
    acceptedAnswers: ["eau"],
    explanation: "Eau is French for water.",
  ),
  TypingQuestion(
    question: "What is the Spanish word for 'house'?",
    acceptedAnswers: ["casa"],
    explanation: "Casa means house in Spanish.",
  ),
  TypingQuestion(
    question: "Type the English translation of '고양이':",
    acceptedAnswers: ["cat", "cats"],
    explanation: "고양이 (goyangi) means cat in Korean.",
  ),
  TypingQuestion(
    question: "What is the Japanese word for 'book'?",
    acceptedAnswers: ["hon", "ほん", "本"],
    explanation: "Hon (ほん/本) means book in Japanese.",
  ),
  TypingQuestion(
    question: "Type the French word for 'hello':",
    acceptedAnswers: ["bonjour", "salut"],
    explanation: "Bonjour or salut mean hello in French.",
  ),
  TypingQuestion(
    question: "What is the Portuguese word for 'thank you'?",
    acceptedAnswers: ["obrigado", "obrigada"],
    explanation: "Obrigado/obrigada means thank you in Portuguese.",
  ),
  TypingQuestion(
    question: "Type the English translation of 'libro':",
    acceptedAnswers: ["book", "books"],
    explanation: "Libro means book in Spanish.",
  ),
  TypingQuestion(
    question: "What is the Korean word for 'water'?",
    acceptedAnswers: ["물", "mul"],
    explanation: "물 (mul) means water in Korean.",
  ),
];

List<MatchingQuestion> sampleMatchingQuestions = [
  MatchingQuestion(
    title: "Match Korean words with English meanings",
    pairs: {
      "사과": "apple",
      "물": "water",
      "책": "book",
      "고양이": "cat",
    },
    explanation: "These are basic Korean vocabulary words.",
  ),
  MatchingQuestion(
    title: "Match languages with their flags",
    pairs: {
      "English": "🇺🇸",
      "Vietnamese": "🇻🇳",
      "Spanish": "🇪🇸",
      "French": "🇫🇷",
    },
    explanation: "Each language is represented by its country's flag.",
  ),
  MatchingQuestion(
    title: "Match Spanish words with English meanings",
    pairs: {
      "casa": "house",
      "libro": "book",
      "agua": "water",
      "gato": "cat",
    },
    explanation: "These are common Spanish vocabulary words.",
  ),
  MatchingQuestion(
    title: "Match French words with English meanings",
    pairs: {
      "chat": "cat",
      "eau": "water",
      "livre": "book",
      "maison": "house",
    },
    explanation: "These are basic French vocabulary words.",
  ),
  MatchingQuestion(
    title: "Match greetings with their languages",
    pairs: {
      "Hello": "English",
      "Hola": "Spanish",
      "Bonjour": "French",
      "안녕하세요": "Korean",
    },
    explanation: "Common greetings in different languages.",
  ),
  MatchingQuestion(
    title: "Match numbers with languages",
    pairs: {
      "One": "English",
      "Uno": "Spanish",
      "Un": "French",
      "하나": "Korean",
    },
    explanation: "The number 'one' in different languages.",
  ),
  MatchingQuestion(
    title: "Match colors with their Spanish translations",
    pairs: {
      "Red": "Rojo",
      "Blue": "Azul",
      "Green": "Verde",
      "Yellow": "Amarillo",
    },
    explanation: "Basic color names in Spanish.",
  ),
  MatchingQuestion(
    title: "Match Japanese characters with meanings",
    pairs: {
      "猫": "cat",
      "犬": "dog",
      "本": "book",
      "水": "water",
    },
    explanation: "Basic Japanese kanji characters.",
  ),
  MatchingQuestion(
    title: "Match countries with their languages",
    pairs: {
      "France": "French",
      "Spain": "Spanish",
      "Korea": "Korean",
      "Japan": "Japanese",
    },
    explanation: "Countries and their primary languages.",
  ),
  MatchingQuestion(
    title: "Match Vietnamese words with English meanings",
    pairs: {
      "mèo": "cat",
      "nước": "water",
      "sách": "book",
      "nhà": "house",
    },
    explanation: "Common Vietnamese vocabulary words.",
  ),
];

// --- Persistence helpers ---
Future<void> _saveString(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> _saveInt(String key, int value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}

Future<void> _saveChatMessages() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = _chatMessages.map((m) => m.toJson()).toList();
  await prefs.setString('chatMessages', jsonEncode(jsonList));
}

Future<void> initGlobals() async {
  final prefs = await SharedPreferences.getInstance();
  _userEmail = prefs.getString('userEmail') ?? _userEmail;
  _userName = prefs.getString('userName') ?? _userName;
  _userBirthYear = prefs.getString('userBirthYear') ?? _userBirthYear;
  _selectedIndex = prefs.getInt('selectedIndex') ?? _selectedIndex;
  final chatJson = prefs.getString('chatMessages');
  if (chatJson != null) {
    final List<dynamic> decoded = jsonDecode(chatJson);
    _chatMessages = decoded.map((e) => ChatMessage.fromJson(e)).toList();
  }
}

