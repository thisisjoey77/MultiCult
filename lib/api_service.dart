import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  // Replace with your actual AWS Lightsail server URL
  static const String baseUrl = 'http://3.35.144.11:8000';

  // Vocabulary API calls
  static Future<List<VocabItem>> getRandomVocabs({
    int count = 50,
    String? category,
  }) async {
    try {
      String url = '$baseUrl/vocabs/random?count=$count';
      if (category != null) {
        url += '&category=$category';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> vocabs = data['vocabs'];
        return vocabs.map((vocab) => VocabItem.fromJson(vocab)).toList();
      } else {
        throw Exception('Failed to load vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching random vocabs: $e');
      throw Exception('Network error: $e');
    }
  }

  // Translation API calls
  static Future<Translation?> getTranslation(int wordId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/translations/$wordId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Translation.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Translation not found
      } else {
        throw Exception('Failed to load translation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching translation for word_id $wordId: $e');
      return null;
    }
  }

  // Definition API calls
  static Future<Definition?> getDefinition(int wordId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/definitions/$wordId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Definition.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Definition not found
      } else {
        throw Exception('Failed to load definition: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching definition for word_id $wordId: $e');
      return null;
    }
  }

  // Search API calls
  static Future<List<SearchResult>> searchWords(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((result) => SearchResult.fromJson(result)).toList();
      } else {
        throw Exception('Failed to search words: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching words: $e');
      return [];
    }
  }

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}

// Data models
class VocabItem {
  final int wordId;
  final String word;
  final String category;

  VocabItem({required this.wordId, required this.word, required this.category});

  factory VocabItem.fromJson(Map<String, dynamic> json) {
    return VocabItem(
      wordId: json['word_id'],
      word: json['word'],
      category: json['category'],
    );
  }
}

class Translation {
  final int wordId;
  final String? eng;
  final String? chn;
  final String? phl;
  final String? vnm;
  final String? esp;

  Translation({
    required this.wordId,
    this.eng,
    this.chn,
    this.phl,
    this.vnm,
    this.esp,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      wordId: json['word_id'],
      eng: json['ENG'],
      chn: json['CHN'],
      phl: json['PHL'],
      vnm: json['VNM'],
      esp: json['ESP'],
    );
  }

  // Get translation for specific language code
  String? getTranslation(String languageCode) {
    switch (languageCode.toUpperCase()) {
      case 'ENG':
        return eng;
      case 'CHN':
        return chn;
      case 'PHL':
        return phl;
      case 'VNM':
        return vnm;
      case 'ESP':
        return esp;
      default:
        return null;
    }
  }
}

class Definition {
  final int wordId;
  final String? kor;
  final String? eng;
  final String? chn;
  final String? phl;
  final String? vnm;
  final String? esp;

  Definition({
    required this.wordId,
    this.kor,
    this.eng,
    this.chn,
    this.phl,
    this.vnm,
    this.esp,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      wordId: json['word_id'],
      kor: json['KOR'],
      eng: json['ENG'],
      chn: json['CHN'],
      phl: json['PHL'],
      vnm: json['VNM'],
      esp: json['ESP'],
    );
  }

  // Get definition for specific language code
  String? getDefinition(String languageCode) {
    switch (languageCode.toUpperCase()) {
      case 'KOR':
        return kor;
      case 'ENG':
        return eng;
      case 'CHN':
        return chn;
      case 'PHL':
        return phl;
      case 'VNM':
        return vnm;
      case 'ESP':
        return esp;
      default:
        return null;
    }
  }
}

class SearchResult {
  final int wordId;
  final String word;
  final String category;
  final Translation translations;

  SearchResult({
    required this.wordId,
    required this.word,
    required this.category,
    required this.translations,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      wordId: json['word_id'],
      word: json['word'],
      category: json['category'],
      translations: Translation(
        wordId: json['word_id'],
        eng: json['translations']['ENG'],
        chn: json['translations']['CHN'],
        phl: json['translations']['PHL'],
        vnm: json['translations']['VNM'],
        esp: json['translations']['ESP'],
      ),
    );
  }
}

// Language helper class
class LanguageHelper {
  // Map frontend language indices to backend language codes
  static const Map<int, String> languageCodeMap = {
    0: 'ENG', // English
    1: 'VNM', // Vietnamese
    2: 'ESP', // Español
    3: 'CHN', // Chinese (replacing French)
    4: 'PHL', // Philippine/Tagalog (replacing Japanese)
  };

  static const Map<int, String> languageNameMap = {
    0: 'English',
    1: 'Vietnamese',
    2: 'Spanish',
    3: 'Chinese',
    4: 'Philippine/Tagalog',
  };

  static String getLanguageCode(int selectedIndex) {
    return languageCodeMap[selectedIndex] ?? 'ENG';
  }

  static String getLanguageName(int selectedIndex) {
    return languageNameMap[selectedIndex] ?? 'English';
  }
}

// Medical categories helper class
class CategoryHelper {
  static const Map<String, String> categories = {
    'ALL': 'All Categories',
    'body_parts': 'Body Parts',
    'illnesses_and_symptoms': 'Illnesses & Symptoms',
    'hygiene_and_safety': 'Hygiene & Safety',
    'nutrition_and_food': 'Nutrition & Food',
    'emotions_and_feelings': 'Emotions & Mental Health',
    'doctor_instructions': 'Medical Instructions',
  };

  static const Map<String, String> categoryDescriptions = {
    'ALL': 'Questions from all medical categories',
    'body_parts': 'Learn body part names and anatomy terms',
    'illnesses_and_symptoms': 'Common illnesses, symptoms, and conditions',
    'hygiene_and_safety': 'Health safety and hygiene practices',
    'nutrition_and_food': 'Nutrition advice and dietary terms',
    'emotions_and_feelings': 'Mental health and emotional wellbeing',
    'doctor_instructions': 'Medical instructions and procedures',
  };

  static final Map<String, IconData> categoryIcons = {
    'ALL': Icons.apps,
    'body_parts': Icons.accessibility_new,
    'illnesses_and_symptoms': Icons.local_hospital,
    'hygiene_and_safety': Icons.clean_hands,
    'nutrition_and_food': Icons.restaurant,
    'emotions_and_feelings': Icons.psychology,
    'doctor_instructions': Icons.medical_services,
  };

  static String getCategoryName(String categoryCode) {
    return categories[categoryCode] ?? 'Unknown Category';
  }

  static String getCategoryDescription(String categoryCode) {
    return categoryDescriptions[categoryCode] ?? 'Medical vocabulary category';
  }

  static IconData getCategoryIcon(String categoryCode) {
    return categoryIcons[categoryCode] ?? Icons.help;
  }

  static List<String> getAllCategoryCodes() {
    return categories.keys.toList();
  }
}
