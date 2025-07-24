import 'dart:math';
import 'api_service.dart';
import 'globals.dart' as globals;

class QuizGenerator {
  static const int defaultQuestionCount = 10;
  static const int mcqOptionsCount = 4;

  // Generate quiz questions based on type and user's selected language
  static Future<List<dynamic>> generateQuiz(
    globals.QuizType type, {
    int questionCount = defaultQuestionCount,
    String? selectedCategory,
  }) async {
    try {
      // Get user's selected language code
      String selectedLanguageCode = LanguageHelper.getLanguageCode(
        globals.selectedIndex,
      );
      String selectedLanguageName = LanguageHelper.getLanguageName(
        globals.selectedIndex,
      );

      print(
        'Generating quiz for language: $selectedLanguageName ($selectedLanguageCode)',
      );

      if (selectedCategory != null) {
        print('Using category filter: $selectedCategory');
      }

      // Fetch vocabulary from backend (we'll get more than needed to ensure variety)
      List<VocabItem> vocabItems = await ApiService.getRandomVocabs(
        count: questionCount * 3,
        category: selectedCategory == 'ALL' ? null : selectedCategory,
      );

      if (vocabItems.isEmpty) {
        throw Exception('No vocabulary items available');
      }

      List<dynamic> questions = [];

      switch (type) {
        case globals.QuizType.mcq:
          questions = await _generateMCQQuestions(
            vocabItems,
            selectedLanguageCode,
            selectedLanguageName,
            questionCount,
          );
          break;
        case globals.QuizType.typing:
          questions = await _generateTypingQuestions(
            vocabItems,
            selectedLanguageCode,
            selectedLanguageName,
            questionCount,
          );
          break;
        case globals.QuizType.matching:
          questions = await _generateMatchingQuestions(
            vocabItems,
            selectedLanguageCode,
            selectedLanguageName,
            questionCount,
          );
          break;
        case globals.QuizType.mixed:
          // Generate mixed questions (33% each type, remainder goes to MCQ)
          int mcqCount = (questionCount * 0.4).ceil();
          int typingCount = (questionCount * 0.3).floor();
          int matchingCount = questionCount - mcqCount - typingCount;

          List<dynamic> mcqQuestions = await _generateMCQQuestions(
            vocabItems,
            selectedLanguageCode,
            selectedLanguageName,
            mcqCount,
          );
          List<dynamic> typingQuestions = await _generateTypingQuestions(
            vocabItems,
            selectedLanguageCode,
            selectedLanguageName,
            typingCount,
          );
          List<dynamic> matchingQuestions = await _generateMatchingQuestions(
            vocabItems,
            selectedLanguageCode,
            selectedLanguageName,
            matchingCount,
          );

          questions = [
            ...mcqQuestions,
            ...typingQuestions,
            ...matchingQuestions,
          ];
          questions.shuffle();
          break;
      }

      return questions.take(questionCount).toList();
    } catch (e) {
      print('Error generating quiz: $e');
      // Fall back to dummy data if API fails
      return _getFallbackQuestions(type, questionCount);
    }
  }

  // Generate MCQ questions (Korean word -> Selected language translation AND vice versa)
  static Future<List<globals.MCQQuestion>> _generateMCQQuestions(
    List<VocabItem> vocabItems,
    String languageCode,
    String languageName,
    int count,
  ) async {
    List<globals.MCQQuestion> questions = [];
    Random random = Random();

    // Get unique vocabulary items
    Set<int> usedWordIds = {};
    List<VocabItem> availableVocab = vocabItems
        .where((item) => !usedWordIds.contains(item.wordId))
        .toList();

    for (int i = 0; i < count && availableVocab.isNotEmpty; i++) {
      VocabItem correctVocab =
          availableVocab[random.nextInt(availableVocab.length)];
      usedWordIds.add(correctVocab.wordId);
      availableVocab.removeWhere((item) => item.wordId == correctVocab.wordId);

      // Get translation for the correct answer
      Translation? correctTranslation = await ApiService.getTranslation(
        correctVocab.wordId,
      );
      String? translatedWord = correctTranslation?.getTranslation(languageCode);

      if (translatedWord == null || translatedWord.isEmpty) {
        continue; // Skip if no translation available
      }

      // Randomly choose direction: 50% Korean→Language, 50% Language→Korean
      bool koreanToLanguage = random.nextBool();

      String question;
      String correctAnswer;
      List<String> wrongAnswers = [];

      if (koreanToLanguage) {
        // Korean → Selected Language
        question = "What does '${correctVocab.word}' mean in $languageName?";
        correctAnswer = translatedWord;

        // Get wrong answers from other translations
        List<VocabItem> otherVocab = List.from(availableVocab)..shuffle(random);

        for (VocabItem otherItem in otherVocab) {
          if (wrongAnswers.length >= mcqOptionsCount - 1) break;

          Translation? otherTranslation = await ApiService.getTranslation(
            otherItem.wordId,
          );
          String? otherAnswer = otherTranslation?.getTranslation(languageCode);

          if (otherAnswer != null &&
              otherAnswer.isNotEmpty &&
              otherAnswer != correctAnswer &&
              !wrongAnswers.contains(otherAnswer)) {
            wrongAnswers.add(otherAnswer);
          }
        }

        // Add generic options if needed
        if (wrongAnswers.length < mcqOptionsCount - 1) {
          List<String> genericOptions = _getGenericOptions(
            languageCode,
            correctAnswer,
          );
          for (String generic in genericOptions) {
            if (wrongAnswers.length >= mcqOptionsCount - 1) break;
            if (!wrongAnswers.contains(generic)) {
              wrongAnswers.add(generic);
            }
          }
        }
      } else {
        // Selected Language → Korean
        question = "What does '$translatedWord' mean in Korean?";
        correctAnswer = correctVocab.word;

        // Get wrong answers from other Korean words
        List<VocabItem> otherVocab = List.from(availableVocab)..shuffle(random);

        for (VocabItem otherItem in otherVocab) {
          if (wrongAnswers.length >= mcqOptionsCount - 1) break;

          if (otherItem.word != correctAnswer &&
              !wrongAnswers.contains(otherItem.word)) {
            wrongAnswers.add(otherItem.word);
          }
        }

        // Add generic Korean medical terms if needed
        if (wrongAnswers.length < mcqOptionsCount - 1) {
          List<String> genericKoreanOptions = _getGenericKoreanOptions(
            correctAnswer,
          );
          for (String generic in genericKoreanOptions) {
            if (wrongAnswers.length >= mcqOptionsCount - 1) break;
            if (!wrongAnswers.contains(generic)) {
              wrongAnswers.add(generic);
            }
          }
        }
      }

      // Create options list
      List<String> options = [correctAnswer, ...wrongAnswers];

      // Ensure we have exactly 4 options
      while (options.length < mcqOptionsCount) {
        options.add("Option ${options.length + 1}");
      }

      // Take only the first 4 options and shuffle
      options = options.take(mcqOptionsCount).toList();
      options.shuffle(random);
      int correctIndex = options.indexOf(correctAnswer);

      // Create explanation
      String explanation = _generateBidirectionalExplanation(
        correctVocab.word,
        translatedWord,
        languageName,
        correctVocab.category,
        koreanToLanguage,
      );

      questions.add(
        globals.MCQQuestion(
          question: question,
          options: options,
          correctIndex: correctIndex,
          explanation: explanation,
        ),
      );
    }

    return questions;
  }

  // Generate typing questions (Korean word -> type translation in selected language AND vice versa)
  static Future<List<globals.TypingQuestion>> _generateTypingQuestions(
    List<VocabItem> vocabItems,
    String languageCode,
    String languageName,
    int count,
  ) async {
    List<globals.TypingQuestion> questions = [];
    Random random = Random();

    Set<int> usedWordIds = {};
    List<VocabItem> availableVocab = vocabItems
        .where((item) => !usedWordIds.contains(item.wordId))
        .toList();

    for (int i = 0; i < count && availableVocab.isNotEmpty; i++) {
      VocabItem vocab = availableVocab[random.nextInt(availableVocab.length)];
      usedWordIds.add(vocab.wordId);
      availableVocab.removeWhere((item) => item.wordId == vocab.wordId);

      Translation? translation = await ApiService.getTranslation(vocab.wordId);
      String? translatedWord = translation?.getTranslation(languageCode);

      if (translatedWord == null || translatedWord.isEmpty) {
        continue; // Skip if no translation available
      }

      // Randomly choose direction: 50% Korean→Language, 50% Language→Korean
      bool koreanToLanguage = random.nextBool();

      String question;
      List<String> acceptedAnswers;

      if (koreanToLanguage) {
        // Korean → Selected Language
        question = "Type the $languageName translation of '${vocab.word}':";
        acceptedAnswers = [translatedWord, translatedWord.toLowerCase()];

        // Add common variations if applicable
        if (translatedWord.contains(' ')) {
          acceptedAnswers.add(translatedWord.replaceAll(' ', ''));
        }
      } else {
        // Selected Language → Korean
        question = "Type the Korean translation of '$translatedWord':";
        acceptedAnswers = [vocab.word];
      }

      String explanation = _generateBidirectionalExplanation(
        vocab.word,
        translatedWord,
        languageName,
        vocab.category,
        koreanToLanguage,
      );

      questions.add(
        globals.TypingQuestion(
          question: question,
          acceptedAnswers: acceptedAnswers,
          explanation: explanation,
        ),
      );
    }

    return questions;
  }

  // Generate matching questions (Korean words <-> Selected language translations)
  static Future<List<globals.MatchingQuestion>> _generateMatchingQuestions(
    List<VocabItem> vocabItems,
    String languageCode,
    String languageName,
    int count,
  ) async {
    List<globals.MatchingQuestion> questions = [];
    Random random = Random();

    // For matching, we need multiple pairs per question
    int pairsPerQuestion = 4;

    for (int i = 0; i < count; i++) {
      Map<String, String> pairs = {};
      Set<int> usedWordIds = {};

      // Get pairs for this matching question
      for (int j = 0; j < pairsPerQuestion; j++) {
        List<VocabItem> availableVocab = vocabItems
            .where((item) => !usedWordIds.contains(item.wordId))
            .toList();

        if (availableVocab.isEmpty) break;

        VocabItem vocab = availableVocab[random.nextInt(availableVocab.length)];
        usedWordIds.add(vocab.wordId);

        Translation? translation = await ApiService.getTranslation(
          vocab.wordId,
        );
        String? translatedWord = translation?.getTranslation(languageCode);

        if (translatedWord != null && translatedWord.isNotEmpty) {
          pairs[vocab.word] = translatedWord;
        }
      }

      if (pairs.length >= 3) {
        // Need at least 3 pairs for a good matching question
        String title =
            "Match Korean medical terms with their $languageName translations";
        String explanation =
            "These are medical vocabulary terms used in healthcare settings.";

        questions.add(
          globals.MatchingQuestion(
            title: title,
            pairs: pairs,
            explanation: explanation,
          ),
        );
      }
    }

    return questions;
  }

  // Generate bidirectional explanation for questions
  static String _generateBidirectionalExplanation(
    String koreanWord,
    String translation,
    String languageName,
    String category,
    bool koreanToLanguage,
  ) {
    String categoryName = _getCategoryDisplayName(category);
    if (koreanToLanguage) {
      return "'$koreanWord' means '$translation' in $languageName. This is a $categoryName term commonly used in medical settings.";
    } else {
      return "'$translation' means '$koreanWord' in Korean. This is a $categoryName term commonly used in medical settings.";
    }
  }

  // Convert category code to display name
  static String _getCategoryDisplayName(String category) {
    Map<String, String> categoryNames = {
      'body_parts': 'body parts',
      'illnesses_and_symptoms': 'illness and symptom',
      'hygiene_and_safety': 'hygiene and safety',
      'nutrition_and_food': 'nutrition and food',
      'emotions_and_feelings': 'emotional and mental health',
      'doctor_instructions': 'medical instruction',
    };
    return categoryNames[category] ?? 'medical';
  }

  // Get generic options for MCQ when we don't have enough real options
  static List<String> _getGenericOptions(
    String languageCode,
    String correctAnswer,
  ) {
    Map<String, List<String>> genericByLanguage = {
      'ENG': [
        'medicine',
        'doctor',
        'hospital',
        'treatment',
        'patient',
        'clinic',
        'therapy',
        'surgery',
      ],
      'VNM': [
        'thuốc',
        'bác sĩ',
        'bệnh viện',
        'điều trị',
        'bệnh nhân',
        'phòng khám',
        'liệu pháp',
        'phẫu thuật',
      ],
      'ESP': [
        'medicina',
        'doctor',
        'hospital',
        'tratamiento',
        'paciente',
        'clínica',
        'terapia',
        'cirugía',
      ],
      'CHN': ['医生', '医院', '治疗', '病人', '药物', '诊所', '手术', '疗法'],
      'PHL': [
        'gamot',
        'doktor',
        'ospital',
        'paggamot',
        'pasyente',
        'klinika',
        'therapy',
        'operasyon',
      ],
    };

    List<String> options =
        genericByLanguage[languageCode] ?? genericByLanguage['ENG']!;
    return options.where((option) => option != correctAnswer).toList();
  }

  // Get generic Korean medical terms
  static List<String> _getGenericKoreanOptions(String correctAnswer) {
    List<String> genericKorean = [
      '의사',
      '병원',
      '치료',
      '환자',
      '약물',
      '진료소',
      '수술',
      '요법',
      '머리',
      '심장',
      '폐',
      '간',
      '위',
      '눈',
      '귀',
      '코',
      '입',
      '감기',
      '열',
      '기침',
      '두통',
      '복통',
      '어지러움',
      '피로',
    ];
    return genericKorean.where((option) => option != correctAnswer).toList();
  }

  // Fallback to dummy data if API fails
  static List<dynamic> _getFallbackQuestions(globals.QuizType type, int count) {
    switch (type) {
      case globals.QuizType.mcq:
        return globals.sampleMCQQuestions.take(count).toList();
      case globals.QuizType.typing:
        return globals.sampleTypingQuestions.take(count).toList();
      case globals.QuizType.matching:
        return globals.sampleMatchingQuestions.take(count).toList();
      case globals.QuizType.mixed:
        List<dynamic> mixed = [
          ...globals.sampleMCQQuestions.take(count ~/ 3),
          ...globals.sampleTypingQuestions.take(count ~/ 3),
          ...globals.sampleMatchingQuestions.take(count - (2 * (count ~/ 3))),
        ];
        mixed.shuffle();
        return mixed;
    }
  }
}
