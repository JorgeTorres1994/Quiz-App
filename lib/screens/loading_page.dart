import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Iniciar Quiz Anónimo"),
          onPressed: () => auth.loginAnonymously(),
        ),
      ),
    );
  }
}
