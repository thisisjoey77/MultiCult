library multicultproj.globals;

// Language settings
List<Map<String, String>> languages = [
  {'name': 'English', 'flag': '🇺🇸'},
  {'name': 'Vietnamese', 'flag': '🇻🇳'},
  {'name': 'Español', 'flag': '🇪🇸'},
  {'name': 'Français', 'flag': '🇫🇷'},
  {'name': '日本語', 'flag': '🇯🇵'},
];
int selectedIndex = 0;

// User info
String userEmail = 'user@example.com';
String userName = 'Jane Doe';
String userBirthYear = '2000';

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

