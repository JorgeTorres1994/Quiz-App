import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';

class QuizPage extends StatefulWidget {
  final CategoryModel category;

  const QuizPage({super.key, required this.category});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuestionService _service = QuestionService();
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _timeLeft = 10;
  bool _answered = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    _questions = await _service.fetchQuestionsByCategory(widget.category.id);
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _timeLeft = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        _handleAnswer(null);
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _handleAnswer(String? selected) {
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOption = selected;
      if (selected == _questions[_currentIndex].correctAnswer) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentIndex + 1 < _questions.length) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedOption = null;
        });
        _startTimer();
      } else {
        _showResult();
      }
    });
  }

  void _showResult() async {
    final questionCount = _questions.length;
    final category = widget.category;

    await FirebaseFirestore.instance.collection('results').add({
      'user_id': 'anon',
      'score': _score,
      'total': questionCount,
      'category_id': category.id,
      'category_name': category.name,
      'created_at': Timestamp.now(),
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Resultado"),
        content: Text("Tu puntaje final es $_score de $questionCount."),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Volver al inicio"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F3FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FA),
      appBar: AppBar(
        title: Text(
          "Pregunta ${_currentIndex + 1} de ${_questions.length}",
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 3,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "⏱ $_timeLeft s",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: _timeLeft / 10,
            color: Colors.pinkAccent,
            backgroundColor: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D3A5A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final opt = question.options[index];
                  final isCorrect = opt == question.correctAnswer;
                  final isSelected = opt == _selectedOption;
                  final showColor = _answered && isSelected;
                  final backgroundColor = showColor
                      ? (isCorrect ? Colors.green[300] : Colors.red[300])
                      : Colors.white;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        foregroundColor: const Color(0xFF3D3A5A),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _answered ? null : () => _handleAnswer(opt),
                      child: Text(
                        opt,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
