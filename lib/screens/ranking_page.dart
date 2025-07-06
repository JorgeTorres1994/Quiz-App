import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const RankingPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FA),
      appBar: AppBar(
        title: Text("🏆 Ranking: $categoryName"),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
        elevation: 4,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('results')
            .where('category_id', isEqualTo: categoryId)
            .orderBy('score', descending: true)
            .limit(10)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "❌ Error al cargar el ranking.\nIntenta más tarde.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "📭 Aún no hay resultados.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index];
              final score = data['score'];
              final total = data['total'];
              final user = data['user_id'];
              final percent = ((score / total) * 100).toStringAsFixed(1);

              Icon? medal;
              switch (index) {
                case 0:
                  medal = const Icon(Icons.emoji_events, color: Colors.amber, size: 32);
                  break;
                case 1:
                  medal = const Icon(Icons.emoji_events, color: Colors.grey, size: 28);
                  break;
                case 2:
                  medal = const Icon(Icons.emoji_events, color: Colors.brown, size: 28);
                  break;
              }

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF6C63FF),
                        radius: 24,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (medal != null)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: medal,
                        ),
                    ],
                  ),
                  title: Text(
                    "👤 Usuario: $user",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("📊 Puntaje: $score / $total   (${percent}%)"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
