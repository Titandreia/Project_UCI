import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';
import 'login_page.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final uid = snapshot.data!.uid;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (!snapshot.data!.exists) {
                // Documento não existe: podes redirecionar para criar conta/perfil
                return LoginPage(); // Ou outra página para criar perfil
              }

              final data = snapshot.data!.data() as Map<String, dynamic>?;

              final role = (data != null && data.containsKey('role')) ? data['role'] : 'paciente';

              return HomePage(role: role, userId: uid);
            },
          );
        }

        // Utilizador não autenticado
        return LoginPage();
      },
    );
  }
}
