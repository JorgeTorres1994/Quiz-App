import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

class QuestionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QuestionModel>> fetchQuestionsByCategory(String categoryId) async {
    final snapshot = await _db
        .collection('questions')
        .where('category_id', isEqualTo: categoryId)
        .get();

    return snapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
