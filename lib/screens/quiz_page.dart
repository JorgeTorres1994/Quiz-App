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

  /*void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Resultado"),
        content: Text("Puntaje final: $_score de ${_questions.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Volver"),
          )
        ],
      ),
    );
  }*/

  void _showResult() async {
    final questionCount = _questions.length;
    final category = widget.category;

    await FirebaseFirestore.instance.collection('results').add({
      'user_id':
          'anon', // Puedes usar FirebaseAuth.instance.currentUser?.uid si tienes auth real
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
        title: const Text("Resultado"),
        content: Text("Puntaje final: $_score de $questionCount"),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Volver"),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Pregunta ${_currentIndex + 1}/${_questions.length}"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("⏱ $_timeLeft s")),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...question.options.map((opt) {
              final isCorrect = opt == question.correctAnswer;
              final isSelected = opt == _selectedOption;
              final showColor = _answered && isSelected;
              final color = showColor
                  ? (isCorrect ? Colors.green : Colors.red)
                  : Colors.grey[200];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _answered ? null : () => _handleAnswer(opt),
                  child: Text(opt),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
