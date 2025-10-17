import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'perfil_historico_jogo_pacientes.dart';
import 'home_page.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  _PatientsPageState createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  bool? filtrarAtivos;
  String? userRole;
  String? userId;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(role: 'desconhecido', userId: ''),
        ),
      );
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    final role = doc.data()?['role'];

    setState(() {
      userRole = role;
      userId = uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userRole == 'paciente') {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(role: userRole!, userId: userId ?? ''),
                ),
              );
            },
          ),
          title: const Text("Lista de Pacientes"),
          backgroundColor: Colors.white.withOpacity(0.9),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Apenas profissionais têm acesso à lista de pacientes.',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(role: userRole!, userId: userId ?? ''),
              ),
            );
          },
        ),
        title: const Text(
          "Lista de Pacientes",
          style: TextStyle(
            color: Color(0xFF007BFF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
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
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        border: Border.all(color: const Color(0xFF94A8CE), width: 4),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Filtrar:",
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              DropdownButton<bool?>(
                                value: filtrarAtivos,
                                dropdownColor: Colors.white.withOpacity(0.9),
                                style: const TextStyle(color: Colors.black),
                                iconEnabledColor: Colors.black,
                                underline: Container(height: 1, color: Colors.black),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text("Todos")),
                                  DropdownMenuItem(value: true, child: Text("Ativos")),
                                  DropdownMenuItem(value: false, child: Text("Inativos")),
                                ],
                                onChanged: (valor) {
                                  setState(() {
                                    filtrarAtivos = valor;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .where('role', isEqualTo: 'paciente')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      "Erro: ${snapshot.error}",
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final docs = snapshot.data!.docs.where((doc) {
                                  try {
                                    if (filtrarAtivos == null) return true;
                                    return doc['ativo'] == filtrarAtivos;
                                  } catch (_) {
                                    return false;
                                  }
                                }).toList();

                                docs.sort((a, b) {
                                  final nomeA = a['nome']?.toString() ?? a.id;
                                  final nomeB = b['nome']?.toString() ?? b.id;
                                  return nomeA.compareTo(nomeB);
                                });

                                if (docs.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "Não existem pacientes",
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final paciente = docs[index];
                                    final nome = paciente['nome'] ?? paciente.id;
                                    final ativo = paciente['ativo'] ?? false;

                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                        color: ativo ? const Color(0xFFC9F2D0) : const Color(0xFFF5C0C0),
                                        border: Border.all(color: const Color(0xFF94A8CE), width: 3),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PatientProfilePage(pacienteId: paciente.id),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const CircleAvatar(
                                                    backgroundColor: Colors.black,
                                                    radius: 20,
                                                    child: Icon(Icons.person, color: Colors.white, size: 20),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    nome,
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              const Icon(Icons.play_arrow, size: 28, color: Colors.black),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
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
}
