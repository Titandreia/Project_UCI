import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importa as páginas reais
import 'home_page.dart';
import 'criar_conta.dart';
import 'esqueceu_se_palavra_passe.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 🔵 Verifica se existe o documento do utilizador na coleção "usuarios"
      final usuarioRef =
      FirebaseFirestore.instance.collection('usuarios').doc(uid);

      final usuarioSnapshot = await usuarioRef.get();

      if (!usuarioSnapshot.exists) {
        // Se não existir, cria automaticamente com um role "paciente" padrão
        await usuarioRef.set({
          'email': email,
          'role': 'paciente', // Ou outro role padrão
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Primeiro acesso detectado. Perfil criado como "paciente".')),
        );
      }

      // 🔵 Carrega novamente os dados do utilizador
      final data = (await usuarioRef.get()).data();

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados do utilizador inválidos!')),
        );
        return;
      }

      final role = data['role'] as String?;

      if (role == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role do utilizador não definido!')),
        );
        return;
      }

      if (role == 'admin' || role == 'profissional' || role == 'paciente') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(role: role, userId: uid),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role desconhecido!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erro: ${e.message}';
      if (e.code == 'user-not-found') {
        message = 'Utilizador não encontrado!';
      } else if (e.code == 'wrong-password') {
        message = 'Palavra-passe incorreta!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Column(
              children: const [
                Text(
                  'MindRevive',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    fontFamily: 'Serif',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Estimular Mentes, Potenciar Vidas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 120),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail_outline, size: 22),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                        hintText: 'exemplo@email.com',
                        labelText: 'E-mail',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 22),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                        hintText: '********',
                        labelText: 'Palavra-passe',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Esqueci-me da palavra-passe',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.blueAccent),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () => _login(context),
                      child: const Text(
                        'INICIAR SESSÃO',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateAccountPage()),
                      ),
                      icon: const Icon(Icons.person_add_alt_1,
                          color: Colors.blueAccent),
                      label: const Text(
                        'CRIAR CONTA',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
