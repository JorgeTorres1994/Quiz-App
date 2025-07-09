import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz_app/screens/login_register_page.dart';
import 'package:quiz_app/seed_firestore.dart';
import 'providers/auth_provider.dart';
import 'screens/home_page.dart';
import 'screens/loading_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ sin opciones porque tienes google-services.json
  await seedFirestore();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Quiz App',
        theme: ThemeData(useMaterial3: true),
        home: const RootPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const LoadingPage(); // ✅ loader temporal
    }

    if (authProvider.user == null) {
      return const LoginRegisterPage(); // ✅ mostrar opciones de ingreso
    } else {
      return const HomePage(); // ✅ usuario logueado
    }
  }
}
