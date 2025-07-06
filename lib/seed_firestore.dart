import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> seedFirestore() async {
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;

  /// 🔄 1. LIMPIEZA: eliminar datos anteriores para evitar duplicados
  Future<void> _deleteCollection(
    FirebaseFirestore db,
    String collectionPath,
  ) async {
    final snapshot = await db.collection(collectionPath).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  await _deleteCollection(firestore, 'categories');
  await _deleteCollection(firestore, 'questions');

  /// 📂 2. CATEGORÍAS
  final categories = [
    {
      'name': 'Cultura General',
      'description': 'Preguntas variadas de conocimiento general',
      'image_url': 'https://cdn-icons-png.flaticon.com/128/5267/5267919.png',
    },
    {
      'name': 'Ciencia',
      'description': 'Física, química, biología y más',
      'image_url': 'https://cdn-icons-png.flaticon.com/128/3890/3890367.png',
    },
    {
      'name': 'Geografía',
      'description': 'Capitales, países y mapas',
      'image_url': 'https://cdn-icons-png.flaticon.com/128/854/854878.png',
    },
  ];

  final categoryRefs = <String, String>{};

  final existing = await firestore.collection('categories').get();
  if (existing.docs.isEmpty) {
    for (final category in categories) {
      final doc = await firestore.collection('categories').add(category);
      categoryRefs[category['name']!] = doc.id;
    }
  }

  /// ❓ 3. PREGUNTAS
  final questions = [
    {
      'category': 'Cultura General',
      'text': '¿Cuál es el idioma más hablado del mundo?',
      'options': ['Inglés', 'Mandarín', 'Español', 'Árabe'],
      'correct_answer': 'Mandarín',
    },
    {
      'category': 'Cultura General',
      'text': '¿Quién escribió "Cien años de soledad"?',
      'options': [
        'Mario Vargas Llosa',
        'Gabriel García Márquez',
        'Pablo Neruda',
        'Julio Cortázar',
      ],
      'correct_answer': 'Gabriel García Márquez',
    },
    {
      'category': 'Ciencia',
      'text': '¿Cuál es el símbolo químico del oro?',
      'options': ['Au', 'Ag', 'Fe', 'Pb'],
      'correct_answer': 'Au',
    },
    {
      'category': 'Ciencia',
      'text': '¿Qué planeta es conocido como el planeta rojo?',
      'options': ['Venus', 'Júpiter', 'Marte', 'Saturno'],
      'correct_answer': 'Marte',
    },
    {
      'category': 'Geografía',
      'text': '¿Cuál es la capital de Australia?',
      'options': ['Sídney', 'Melbourne', 'Canberra', 'Brisbane'],
      'correct_answer': 'Canberra',
    },
    {
      'category': 'Geografía',
      'text': '¿Qué río es el más largo del mundo?',
      'options': ['Amazonas', 'Nilo', 'Yangtsé', 'Misisipi'],
      'correct_answer': 'Nilo',
    },
  ];

  for (final q in questions) {
    final categoryId = categoryRefs[q['category']]!;
    await firestore.collection('questions').add({
      'category_id': categoryId,
      'text': q['text'],
      'options': q['options'],
      'correct_answer': q['correct_answer'],
    });
  }

  print('✔ Datos de prueba insertados correctamente y sin duplicados.');
}
