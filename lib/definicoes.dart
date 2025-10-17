import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notificacoes.dart';
import 'help_and_support_page.dart';
import 'provacidade.dart';
import 'perguntas_frequentes.dart';
import 'home_page.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<String> _getRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return 'paciente';

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.data()?['role'] ?? 'paciente';
  }

  // Atualizado: Apagar conta → definir apagado e ativo como false
  Future<void> _apagarConta(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(userId).update({
        'apagado': true,
        'ativo': false, // ← Isto garante que o paciente fica inativo (vermelho)
      });

      final historyRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('History_Games');
      final historySnapshot = await historyRef.get();
      for (var doc in historySnapshot.docs) {
        await doc.reference.update({'apagado': true});
      }

      final user = FirebaseAuth.instance.currentUser;
      await user?.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta apagada com sucesso!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao apagar conta: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Image_1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'DEFINIÇÕES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF007BFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      children: [
                        buildMenuButton(context, "NOTIFICAÇÕES", const NotificationsPage()),
                        const SizedBox(height: 20),
                        buildMenuButton(context, "AJUDA E SUPORTE", const HelpAndSupportPage()),
                        const SizedBox(height: 20),
                        buildMenuButton(context, "PRIVACIDADE", const PrivacyPage()),
                        const SizedBox(height: 20),
                        buildMenuButton(context, "QUESTÕES", const QuestionsPage()),
                        const SizedBox(height: 60),
                        buildActionButton(
                          context,
                          "GUARDAR",
                          const Color(0xFF6EBF8B),
                              () async {
                            final role = await _getRole();
                            _showConfirmationDialog(
                              context,
                              "Guardar Alterações",
                              "Tens a certeza que queres guardar as alterações?",
                              "SIM",
                              "NÃO",
                                  () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomePage(role: role, userId: userId),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        buildActionButton(
                          context,
                          "TERMINAR SESSÃO",
                          const Color(0xFFD95C5C),
                              () async {
                            _showConfirmationDialog(
                              context,
                              "Terminar Sessão",
                              "Tens a certeza que queres terminar a sessão?",
                              "SIM",
                              "NÃO",
                                  () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        buildActionButton(
                          context,
                          "APAGAR CONTA",
                          Colors.red,
                              () async {
                            _showConfirmationDialog(
                              context,
                              "Apagar Conta",
                              "Tens a certeza que queres apagar a tua conta? Esta ação é irreversível.",
                              "SIM",
                              "NÃO",
                                  () async {
                                await _apagarConta(context, userId);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton(BuildContext context, String label, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6CA6CD),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 4,
      ),
      child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget buildActionButton(BuildContext context, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        elevation: 4,
        minimumSize: const Size(160, 50),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _showConfirmationDialog(
      BuildContext context,
      String title,
      String message,
      String confirmLabel,
      String cancelLabel,
      VoidCallback onConfirm,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD95C5C), width: 2),
        ),
        backgroundColor: Colors.white,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF007BFF),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD95C5C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(confirmLabel,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6EBF8B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(cancelLabel,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
