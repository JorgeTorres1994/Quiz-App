import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid ?? '';
    final isAnon = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

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

          final allDocs = snapshot.data?.docs ?? [];

          // Filtrar si el usuario NO es anónimo
          /*final filteredDocs = isAnon
              ? allDocs
              : allDocs.where((doc) => doc['is_anonymous'] == false).toList();*/

          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data.containsKey('is_anonymous')
                ? (isAnon ? true : data['is_anonymous'] == false)
                : false; // ignora los que no tienen el campo
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text("📭 Aún no hay resultados."));
          }

          int? myPosition;
          QueryDocumentSnapshot? myDoc;
          for (int i = 0; i < filteredDocs.length; i++) {
            if (filteredDocs[i]['user_id'] == currentUid) {
              myPosition = i + 1;
              myDoc = filteredDocs[i];
              break;
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length > 10
                      ? 10
                      : filteredDocs.length,
                  itemBuilder: (_, index) {
                    final data = filteredDocs[index];
                    final score = data['score'];
                    final total = data['total'];
                    final uid = data['user_id'];
                    final name = data['user_name'] ?? 'Usuario';
                    final percent = ((score / total) * 100).toStringAsFixed(1);
                    final isCurrent = uid == currentUid;

                    Icon? medal;
                    switch (index) {
                      case 0:
                        medal = const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 32,
                        );
                        break;
                      case 1:
                        medal = const Icon(
                          Icons.emoji_events,
                          color: Colors.grey,
                          size: 28,
                        );
                        break;
                      case 2:
                        medal = const Icon(
                          Icons.emoji_events,
                          color: Colors.brown,
                          size: 28,
                        );
                        break;
                    }

                    return Card(
                      color: isCurrent ? Colors.deepPurple.shade50 : null,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (medal != null)
                              Positioned(top: -2, right: -2, child: medal),
                          ],
                        ),
                        title: Text(
                          isCurrent ? "👤 Tú ($name)" : "👤 $name",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "📊 Puntaje: $score / $total   (${percent}%)",
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (myPosition != null && myPosition > 10 && myDoc != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "📌 Tu posición",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  color: Colors.deepPurple.shade100,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6C63FF),
                      child: Text(
                        "$myPosition",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text("👤 Tú (${myDoc['user_name'] ?? 'Usuario'})"),
                    subtitle: Text(
                      "📊 Puntaje: ${myDoc['score']} / ${myDoc['total']}   (${((myDoc['score'] / myDoc['total']) * 100).toStringAsFixed(1)}%)",
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
