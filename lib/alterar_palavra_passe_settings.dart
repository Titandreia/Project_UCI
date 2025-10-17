import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _atualController = TextEditingController();
  final TextEditingController _novaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  Future<String> _getRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return 'paciente';
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.data()?['role'] ?? 'paciente';
  }

  Future<void> _alterarPalavraPasse() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    if (_atualController.text.isEmpty ||
        _novaController.text.isEmpty ||
        _confirmarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos.")),
      );
      return;
    }

    if (_novaController.text != _confirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As novas palavras-passe não coincidem.")),
      );
      return;
    }

    try {
      // 1️⃣ Reautenticar o utilizador
      final cred = EmailAuthProvider.credential(
        email: email,
        password: _atualController.text,
      );
      await user!.reauthenticateWithCredential(cred);

      // 2️⃣ Atualizar a palavra-passe
      await user.updatePassword(_novaController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Palavra-passe alterada com sucesso!")),
      );

      // 3️⃣ Voltar ao HomePage com role e userId corretos
      final role = await _getRole();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(role: role, userId: user.uid),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = "Erro: ${e.message}";
      if (e.code == 'wrong-password') {
        message = "Palavra-passe atual incorreta.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com imagem
          Positioned.fill(
            child: Image.asset(
              'assets/images/Image_1.png',
              fit: BoxFit.cover,
            ),
          ),
          // Conteúdo principal
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Barra de título
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
                            'ALTERAR PALAVRA-PASSE',
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

                  // Cartão de alteração de palavra-passe
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF94A8CE), width: 3),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextField("Palavra-passe atual", _atualController, true),
                            const SizedBox(height: 12),
                            buildTextField("Nova palavra-passe", _novaController, true),
                            const SizedBox(height: 12),
                            buildTextField("Confirmar nova palavra-passe", _confirmarController, true),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _showConfirmationDialog(
                                  "Tem a certeza que quer alterar a palavra-passe?",
                                  _alterarPalavraPasse,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6EBF8B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                elevation: 4,
                              ),
                              child: const Text("ALTERAR", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
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
    );
  }

  Widget buildTextField(String label, TextEditingController controller, bool obscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        backgroundColor: Colors.white,
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
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("SIM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("NÃO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}