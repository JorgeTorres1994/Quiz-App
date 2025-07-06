class QuestionModel {
  final String id;
  final String text;
  final List<String> options;
  final String correctAnswer;
  final String categoryId;

  QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.categoryId,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> data, String id) {
    return QuestionModel(
      id: id,
      text: data['text'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correct_answer'] ?? '',
      categoryId: data['category_id'] ?? '',
    );
  }
}
