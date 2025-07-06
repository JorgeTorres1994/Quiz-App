import 'package:flutter/material.dart';
import 'package:quiz_app/screens/quiz_page.dart';
import 'package:quiz_app/screens/ranking_page.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CategoryService _service = CategoryService();
  late Future<List<CategoryModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FA),
      appBar: AppBar(
        title: const Text("🧠 Quiz App"),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 3,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay categorías disponibles"));
          }

          final categories = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final cat = categories[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuizPage(category: cat)),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.6,
                          child: Image.network(
                            cat.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF3D3A5A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7E7C9C),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RankingPage(
                                          categoryId: cat.id,
                                          categoryName: cat.name,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE25D9B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text(
                                    "Ver Ranking",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
