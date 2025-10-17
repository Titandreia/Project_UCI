import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedRole = 'profissional'; // padrão
  String _selectedSexo = 'Prefiro não dizer'; // novo campo

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime(2000);
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  Future<void> _criarConta() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final dataAniversario = _selectedDate;
    final password = passwordController.text.trim();
    final confirmarPassword = confirmPasswordController.text.trim();
    final codigo = codigoController.text.trim();
    final sexo = _selectedSexo;

    if (nome.isEmpty || email.isEmpty || dataAniversario == null || password.isEmpty || confirmarPassword.isEmpty || codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    // Busca o código válido do Firestore
    String codigoValido = '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('codigos_autorizacao')
          .doc('medico_responsavel')
          .get();

      if (doc.exists && doc.data() != null && doc.data()!.containsKey('codigo')) {
        codigoValido = doc['codigo'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código de autorização não configurado.')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao validar código: ${e.toString()}')),
      );
      return;
    }

    if (codigo != codigoValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de autorização inválido.')),
      );
      return;
    }

    if (password != confirmarPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As palavras-passe não coincidem.')),
      );
      return;
    }

    try {
      // 🔵 Cria o utilizador no Firebase Authentication
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      // 🔵 Dados para Firestore (coleção "usuarios")
      final dadosUser = {
        'nome': nome,
        'e-mail': email,
        'data_de_nascimento': Timestamp.fromDate(dataAniversario),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'ativo': true,
      };

      if (_selectedRole == 'profissional') {
        dadosUser['profissionalId'] = uid;
      } else if (_selectedRole == 'paciente') {
        dadosUser['sexo'] = sexo;
        dadosUser['nivelAtual'] = 1;
        dadosUser['User_number'] = '';
      }

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set(dadosUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );

      Navigator.pop(context); // volta à página de login
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro Firebase Auth: ${e.message}')),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Image_1.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Criar Conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 20), // Reduzido para subir o formulário
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTextField(Icons.person, 'Nome', nomeController),
                          const SizedBox(height: 20),
                          _buildTextField(Icons.mail_outline, 'E-mail', emailController),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _selectDate,
                            child: AbsorbPointer(
                              child: _buildTextField(Icons.calendar_today, 'Data de Nascimento', dobController),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Campo de seleção de sexo
                          DropdownButtonFormField<String>(
                            value: _selectedSexo,
                            decoration: InputDecoration(
                              labelText: 'Sexo',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                              DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                              DropdownMenuItem(value: 'Prefiro não dizer', child: Text('Prefiro não dizer')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSexo = value ?? 'Prefiro não dizer';
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(Icons.lock_outline, 'Palavra-passe', passwordController, isPassword: true),
                          const SizedBox(height: 20),
                          _buildTextField(Icons.lock_outline, 'Confirmar Palavra-passe', confirmPasswordController, isPassword: true),
                          const SizedBox(height: 20),
                          _buildTextField(Icons.verified_user, 'Código de Autorização', codigoController),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Tipo de conta',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'profissional', child: Text('Profissional de Saúde')),
                              DropdownMenuItem(value: 'paciente', child: Text('Paciente')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value ?? 'profissional';
                              });
                            },
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: _criarConta,
                            child: const Text(
                              'CRIAR CONTA',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}