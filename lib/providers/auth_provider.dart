import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  bool _loading = true;
  bool get isLoading => _loading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _loading = false; // ✅ muy importante
      notifyListeners();
    });
  }

  Future<void> loginAnonymously() async {
    _loading = true;
    notifyListeners();

    try {
      await _auth.signInAnonymously();
    } catch (e) {
      // Puedes imprimir el error o mostrar un SnackBar
      debugPrint("Error en login anónimo: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
