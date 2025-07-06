import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const RankingPage({super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ranking: $categoryName")),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('results')
            .where('category_id', isEqualTo: categoryId)
            .orderBy('score', descending: true)
            .orderBy('created_at', descending: false)
            .limit(10)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Aún no hay resultados."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index];
              final score = data['score'];
              final total = data['total'];
              final user = data['user_id'];

              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text("Usuario: $user"),
                subtitle: Text("Puntaje: $score / $total"),
              );
            },
          );
        },
      ),
    );
  }
}
