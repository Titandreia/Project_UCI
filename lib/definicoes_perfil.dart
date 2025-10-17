import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'alterar_palavra_passe_settings.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dataNascimentoController = TextEditingController();

  String _sexo = 'Prefiro não dizer';
  File? _profileImage;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nomeController.text = data['nome'] ?? '';
        _emailController.text = data['e-mail'] ?? '';
        if (data['data_de_nascimento'] != null) {
          if (data['data_de_nascimento'] is Timestamp) {
            final dt = (data['data_de_nascimento'] as Timestamp).toDate();
            _selectedDate = dt;
            _dataNascimentoController.text =
                DateFormat('dd/MM/yyyy').format(dt);
          } else {
            _dataNascimentoController.text =
                data['data_de_nascimento'].toString();
          }
        } else {
          _dataNascimentoController.text = '';
        }

        final sexoFirestore = data['sexo'] ?? 'Prefiro não dizer';
        if (sexoFirestore == 'Masculino' ||
            sexoFirestore == 'Feminino' ||
            sexoFirestore == 'Prefiro não dizer') {
          _sexo = sexoFirestore;
        } else {
          _sexo = 'Prefiro não dizer';
        }

        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilizador não encontrado!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  Future<void> _selecionarDataNascimento() async {
    DateTime initialDate = _selectedDate ?? DateTime(2000);
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dataNascimentoController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _guardarAlteracoes() async {
    try {
      final dataNascimentoFirestore = _selectedDate != null
          ? Timestamp.fromDate(_selectedDate!)
          : _dataNascimentoController.text;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .update({
        'nome': _nomeController.text,
        'e-mail': _emailController.text,
        'data_de_nascimento': dataNascimentoFirestore,
        'sexo': _sexo,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alterações guardadas!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () async {
                final photo = await picker.pickImage(
                    source: ImageSource.camera, imageQuality: 70);
                Navigator.pop(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                final photo = await picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 70);
                Navigator.pop(context, photo);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/Image_1.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    color: Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              size: 28, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'PERFIL',
                              style: TextStyle(
                                  color: Color(0xFF007BFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 80),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color(0xFF94A8CE), width: 3),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null,
                                    child: _profileImage == null
                                        ? const Icon(Icons.person,
                                        size: 48, color: Colors.white)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.white, size: 22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildFormField('Nome', _nomeController),
                            const SizedBox(height: 20),
                            _buildFormField('E-mail', _emailController),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _selecionarDataNascimento,
                              child: AbsorbPointer(
                                child: _buildFormField('Data de Nascimento',
                                    _dataNascimentoController,
                                    hint: 'dd/mm/aaaa'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: _sexo,
                              decoration: InputDecoration(
                                labelText: 'Sexo',
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Masculino', child: Text('Masculino')),
                                DropdownMenuItem(
                                    value: 'Feminino', child: Text('Feminino')),
                                DropdownMenuItem(
                                    value: 'Prefiro não dizer',
                                    child: Text('Prefiro não dizer')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _sexo = value ?? 'Prefiro não dizer';
                                });
                              },
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _guardarAlteracoes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6EBF8B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 12),
                                elevation: 4,
                              ),
                              child: const Text("GUARDAR ALTERAÇÕES",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangePasswordPage(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF007BFF),
                                side:
                                const BorderSide(color: Color(0xFF007BFF)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: const Text("ALTERAR PALAVRA-PASSE"),
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

  Widget _buildFormField(String label, TextEditingController controller,
      {String? hint}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
