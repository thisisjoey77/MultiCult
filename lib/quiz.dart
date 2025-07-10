import 'package:flutter/material.dart';
import 'dart:math';
import 'globals.dart' as globals;

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  globals.QuizType? selectedQuizType;
  bool quizStarted = false;
  int currentQuestionIndex = 0;
  int score = 0;
  bool showAnswer = false;
  bool questionAnswered = false;
  
  late AnimationController _progressAnimationController;
  late AnimationController _feedbackAnimationController;
  late Animation<double> _progressAnimation;

  List<dynamic> currentQuiz = [];
  final int totalQuestions = 10;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _feedbackAnimationController.dispose();
    super.dispose();
  }

  void startQuiz(globals.QuizType type) {
    setState(() {
      selectedQuizType = type;
      quizStarted = true;
      currentQuestionIndex = 0;
      score = 0;
      showAnswer = false;
      questionAnswered = false;
      currentQuiz = _generateQuiz(type);
    });
    _progressAnimationController.forward();
  }

  List<dynamic> _generateQuiz(globals.QuizType type) {
    List<dynamic> quiz = [];
    Random random = Random();
    
    switch (type) {
      case globals.QuizType.mcq:
        quiz = List.from(globals.sampleMCQQuestions)..shuffle(random);
        break;
      case globals.QuizType.typing:
        quiz = List.from(globals.sampleTypingQuestions)..shuffle(random);
        break;
      case globals.QuizType.matching:
        quiz = List.from(globals.sampleMatchingQuestions)..shuffle(random);
        break;
      case globals.QuizType.mixed:
        List<dynamic> allQuestions = [
          ...globals.sampleMCQQuestions,
          ...globals.sampleTypingQuestions,
          ...globals.sampleMatchingQuestions,
        ];
        allQuestions.shuffle(random);
        quiz = allQuestions;
        break;
    }
    
    // If we have fewer questions than needed, cycle through them with shuffling
    if (quiz.length < totalQuestions) {
      List<dynamic> extendedQuiz = [];
      while (extendedQuiz.length < totalQuestions) {
        List<dynamic> shuffledCopy = List.from(quiz)..shuffle(random);
        extendedQuiz.addAll(shuffledCopy);
      }
      return extendedQuiz.take(totalQuestions).toList();
    }
    
    return quiz.take(totalQuestions).toList();
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < totalQuestions - 1) {
        currentQuestionIndex++;
        showAnswer = false;
        questionAnswered = false;
        _progressAnimationController.animateTo(
          (currentQuestionIndex + 1) / totalQuestions,
        );
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              score >= totalQuestions * 0.7 ? Icons.celebration : Icons.thumb_up,
              size: 64,
              color: score >= totalQuestions * 0.7 ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $score/$totalQuestions',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${((score / totalQuestions) * 100).round()}%',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                quizStarted = false;
                selectedQuizType = null;
              });
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                quizStarted = false;
                selectedQuizType = null;
              });
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!quizStarted) {
      return _buildQuizTypeSelection();
    }
    
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCurrentQuestion(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizTypeSelection() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Quiz Type',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),
            _buildQuizTypeCard(
              'Multiple Choice',
              'Answer questions with multiple options',
              Icons.quiz,
              Colors.blue,
              () => startQuiz(globals.QuizType.mcq),
            ),
            const SizedBox(height: 16),
            _buildQuizTypeCard(
              'Type the Answer',
              'Type your answers directly',
              Icons.keyboard,
              Colors.green,
              () => startQuiz(globals.QuizType.typing),
            ),
            const SizedBox(height: 16),
            _buildQuizTypeCard(
              'Matching Game',
              'Match items with their pairs',
              Icons.swap_horiz,
              Colors.orange,
              () => startQuiz(globals.QuizType.matching),
            ),
            const SizedBox(height: 16),
            _buildQuizTypeCard(
              'Mixed Quiz',
              'All question types combined',
              Icons.shuffle,
              Colors.purple,
              () => startQuiz(globals.QuizType.mixed),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTypeCard(String title, String description, IconData icon, 
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of $totalQuestions',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                'Score: $score',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value * (currentQuestionIndex + 1) / totalQuestions,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _progressAnimation.value > 0.7 ? Colors.green : Colors.blue,
                ),
                minHeight: 8,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentQuestion() {
    if (currentQuestionIndex >= currentQuiz.length) {
      return const Center(child: Text('Quiz completed!'));
    }

    dynamic question = currentQuiz[currentQuestionIndex];
    
    if (question is globals.MCQQuestion) {
      return _buildMCQQuestion(question);
    } else if (question is globals.TypingQuestion) {
      return _buildTypingQuestion(question);
    } else if (question is globals.MatchingQuestion) {
      return _buildMatchingQuestion(question);
    }
    
    return const Center(child: Text('Invalid question type'));
  }

  Widget _buildMCQQuestion(globals.MCQQuestion question) {
    return MCQWidget(
      key: ValueKey(currentQuestionIndex), // This ensures the widget resets for each question
      question: question,
      onAnswerSelected: (isCorrect, selectedIndex) {
        setState(() {
          questionAnswered = true;
          showAnswer = true;
          if (isCorrect) score++;
        });
        _feedbackAnimationController.forward().then((_) {
          _feedbackAnimationController.reset();
        });
      },
      showAnswer: showAnswer,
      onNext: nextQuestion,
    );
  }

  Widget _buildTypingQuestion(globals.TypingQuestion question) {
    return TypingWidget(
      key: ValueKey(currentQuestionIndex), // This ensures the widget resets for each question
      question: question,
      onAnswerSubmitted: (isCorrect) {
        setState(() {
          questionAnswered = true;
          showAnswer = true;
          if (isCorrect) score++;
        });
        _feedbackAnimationController.forward().then((_) {
          _feedbackAnimationController.reset();
        });
      },
      showAnswer: showAnswer,
      onNext: nextQuestion,
    );
  }

  Widget _buildMatchingQuestion(globals.MatchingQuestion question) {
    return MatchingWidget(
      key: ValueKey(currentQuestionIndex), // This ensures the widget resets for each question
      question: question,
      onCompleted: (correctMatches) {
        setState(() {
          questionAnswered = true;
          showAnswer = true;
          score += correctMatches.toInt();
        });
        _feedbackAnimationController.forward().then((_) {
          _feedbackAnimationController.reset();
        });
      },
      onNext: nextQuestion,
    );
  }
}

// MCQ Widget
class MCQWidget extends StatefulWidget {
  final globals.MCQQuestion question;
  final Function(bool, int) onAnswerSelected;
  final bool showAnswer;
  final VoidCallback onNext;

  const MCQWidget({
    super.key,
    required this.question,
    required this.onAnswerSelected,
    required this.showAnswer,
    required this.onNext,
  });

  @override
  State<MCQWidget> createState() => _MCQWidgetState();
}

class _MCQWidgetState extends State<MCQWidget> with TickerProviderStateMixin {
  int? selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: widget.question.options.length,
            itemBuilder: (context, index) {
              Color? backgroundColor;
              Color? textColor;
              IconData? icon;

              if (widget.showAnswer) {
                if (index == widget.question.correctIndex) {
                  backgroundColor = Colors.green[100];
                  textColor = Colors.green[800];
                  icon = Icons.check_circle;
                } else if (index == selectedIndex && index != widget.question.correctIndex) {
                  backgroundColor = Colors.red[100];
                  textColor = Colors.red[800];
                  icon = Icons.cancel;
                }
              }

              return AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: selectedIndex == index ? _scaleAnimation.value : 1.0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: selectedIndex == index ? 4 : 2,
                        color: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: selectedIndex == index 
                            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                            : BorderSide.none,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.showAnswer ? null : () {
                            setState(() {
                              selectedIndex = index;
                            });
                            _animationController.forward().then((_) {
                              _animationController.reverse();
                            });
                            widget.onAnswerSelected(
                              index == widget.question.correctIndex,
                              index,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selectedIndex == index 
                                      ? Theme.of(context).primaryColor 
                                      : Colors.grey[300],
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: TextStyle(
                                        color: selectedIndex == index 
                                          ? Colors.white 
                                          : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.question.options[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textColor ?? Colors.black87,
                                      fontWeight: selectedIndex == index 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (icon != null) Icon(icon, color: textColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (widget.showAnswer) ...[
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.question.explanation,
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next Question',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Typing Widget
class TypingWidget extends StatefulWidget {
  final globals.TypingQuestion question;
  final Function(bool) onAnswerSubmitted;
  final bool showAnswer;
  final VoidCallback onNext;

  const TypingWidget({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
    required this.showAnswer,
    required this.onNext,
  });

  @override
  State<TypingWidget> createState() => _TypingWidgetState();
}

class _TypingWidgetState extends State<TypingWidget> {
  final TextEditingController _controller = TextEditingController();
  bool? isCorrect;
  bool showOverride = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    String userAnswer = _controller.text.trim().toLowerCase();
    bool correct = widget.question.acceptedAnswers
        .any((answer) => answer.toLowerCase() == userAnswer);
    
    setState(() {
      isCorrect = correct;
      if (!correct) {
        showOverride = true;
      }
    });
    
    widget.onAnswerSubmitted(correct);
  }

  void _overrideAnswer() {
    setState(() {
      isCorrect = true;
    });
    widget.onAnswerSubmitted(true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.question.question,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        const SizedBox(height: 30),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Answer:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  enabled: !widget.showAnswer,
                  decoration: InputDecoration(
                    hintText: 'Type your answer here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    suffixIcon: isCorrect != null
                        ? Icon(
                            isCorrect! ? Icons.check_circle : Icons.cancel,
                            color: isCorrect! ? Colors.green : Colors.red,
                          )
                        : null,
                  ),
                  style: const TextStyle(fontSize: 16),
                  onSubmitted: widget.showAnswer ? null : (_) => _checkAnswer(),
                ),
                const SizedBox(height: 16),
                if (!widget.showAnswer)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _hasText ? _checkAnswer : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Answer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.showAnswer) ...[
          if (isCorrect == false && showOverride) ...[
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Incorrect. Was this actually correct?',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                showOverride = false;
                              });
                            },
                            child: const Text(
                              'No',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _overrideAnswer,
                            child: const Text(
                              'Yes',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Correct answers:',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.question.acceptedAnswers.join(', '),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.question.explanation,
                    style: TextStyle(color: Colors.blue[700]),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next Question',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
      ),
    );
  }
}

// Matching Widget
class MatchingWidget extends StatefulWidget {
  final globals.MatchingQuestion question;
  final Function(int) onCompleted;
  final VoidCallback onNext;

  const MatchingWidget({
    super.key,
    required this.question,
    required this.onCompleted,
    required this.onNext,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> 
    with TickerProviderStateMixin {
  Map<String, String> userMatches = {};
  String? selectedKey;
  String? selectedValue;
  Set<String> correctMatches = {};
  Set<String> incorrectMatches = {};
  bool isCompleted = false;
  
  late List<String> shuffledKeys;
  late List<String> shuffledValues;
  
  late AnimationController _successAnimationController;
  late AnimationController _errorAnimationController;
  late Animation<double> _successAnimation;
  late Animation<double> _errorAnimation;

  @override
  void initState() {
    super.initState();
    shuffledKeys = widget.question.pairs.keys.toList()..shuffle();
    shuffledValues = widget.question.pairs.values.toList()..shuffle();
    
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _successAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _successAnimationController, curve: Curves.easeOut),
    );
    _errorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _successAnimationController.dispose();
    _errorAnimationController.dispose();
    super.dispose();
  }

  void _selectItem(String item, bool isKey) {
    setState(() {
      if (isKey) {
        selectedKey = selectedKey == item ? null : item;
        selectedValue = null;
      } else {
        selectedValue = selectedValue == item ? null : item;
        selectedKey = null;
      }
    });
  }

  void _tryMatch(String key, String value) {
    String correctValue = widget.question.pairs[key]!;
    bool isCorrect = correctValue == value;
    
    if (isCorrect) {
      setState(() {
        userMatches[key] = value;
        correctMatches.add(key);
        correctMatches.add(value);
        selectedKey = null;
        selectedValue = null;
      });
      
      _successAnimationController.forward().then((_) {
        if (userMatches.length == widget.question.pairs.length) {
          setState(() {
            isCompleted = true;
          });
          widget.onCompleted(userMatches.length);
        }
      });
    } else {
      setState(() {
        incorrectMatches.add(key);
        incorrectMatches.add(value);
        selectedKey = null;
        selectedValue = null;
      });
      
      _errorAnimationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            incorrectMatches.remove(key);
            incorrectMatches.remove(value);
          });
          _errorAnimationController.reset();
        });
      });
    }
  }

  void _onItemTap(String item, bool isKey) {
    if (correctMatches.contains(item)) return;
    
    if (isKey) {
      if (selectedValue != null) {
        _tryMatch(item, selectedValue!);
      } else {
        _selectItem(item, true);
      }
    } else {
      if (selectedKey != null) {
        _tryMatch(selectedKey!, item);
      } else {
        _selectItem(item, false);
      }
    }
  }

  Color _getItemColor(String item, bool isKey) {
    if (correctMatches.contains(item)) {
      return Colors.green[100]!;
    } else if (incorrectMatches.contains(item)) {
      return Colors.red[100]!;
    } else if ((isKey && selectedKey == item) || (!isKey && selectedValue == item)) {
      return Colors.blue[100]!;
    }
    return Colors.grey[100]!;
  }

  Widget _buildMatchingItem(String item, bool isKey) {
    bool isMatched = correctMatches.contains(item);
    bool isSelected = (isKey && selectedKey == item) || (!isKey && selectedValue == item);
    bool isIncorrect = incorrectMatches.contains(item);
    
    return AnimatedBuilder(
      animation: isMatched ? _successAnimation : _errorAnimation,
      builder: (context, child) {
        double scale = isIncorrect ? (1.0 + _errorAnimation.value * 0.1) : 1.0;
        double opacity = isMatched ? _successAnimation.value : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Material(
                elevation: isSelected ? 4 : 2,
                borderRadius: BorderRadius.circular(16),
                color: _getItemColor(item, isKey),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isMatched ? null : () => _onItemTap(item, isKey),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected 
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                    ),
                    child: Center(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isMatched ? Colors.green[800] : 
                                 isIncorrect ? Colors.red[800] : 
                                 isSelected ? Colors.blue[800] : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        },
      );
    }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.question.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tap items to match them together',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              // Left column (keys)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Items',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: shuffledKeys.length,
                        itemBuilder: (context, index) {
                          String key = shuffledKeys[index];
                          if (correctMatches.contains(key)) {
                            return const SizedBox.shrink();
                          }
                          return _buildMatchingItem(key, true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right column (values)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Matches',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: shuffledValues.length,
                        itemBuilder: (context, index) {
                          String value = shuffledValues[index];
                          if (correctMatches.contains(value)) {
                            return const SizedBox.shrink();
                          }
                          return _buildMatchingItem(value, false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isCompleted) ...[
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Great job! All matches completed!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.question.explanation,
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next Question',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
