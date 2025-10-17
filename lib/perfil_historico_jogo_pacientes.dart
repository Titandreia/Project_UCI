import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uci_project/lista_pacientes.dart';
import 'nivel_1_page.dart';
import 'nivel_2_page.dart';
import 'nivel_3_page.dart';
import 'nivel_4_page.dart';
import 'hitorico_jogo_detalhes.dart';
import 'home_page.dart';

class PatientProfilePage extends StatelessWidget {
  final String pacienteId;

  const PatientProfilePage({super.key, required this.pacienteId});

  Widget _getNivelPage(int nivel, String userId) {
    switch (nivel) {
      case 1:
        return Nivel1Page(userId: userId);
      case 2:
        return Nivel2Page(userId: userId);
      case 3:
        return Nivel3Page(userId: userId);
      case 4:
        return Nivel4Page(userId: userId);
      default:
        return Nivel1Page(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        leading: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('usuarios').doc(pacienteId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(); // ou ícone loading
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            final role = data['role'] ?? 'paciente';

            return IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientsPage(), // Alterado para ListaPacientesPage
                  ),
                      (Route<dynamic> route) => false, // Remove todas as rotas anteriores
                );
              },
            );
          },
        ),
        title: const Text(
          "PERFIL DO PACIENTE",
          style: TextStyle(
            color: Color(0xFF007BFF),
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(pacienteId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                          final nome = data['nome'] ?? '---';
                          final dataAniversario = data['data_de_nascimento'] != null
                              ? (data['data_de_nascimento'] is Timestamp
                              ? (data['data_de_nascimento'] as Timestamp).toDate().toLocal().toString().substring(0, 10)
                              : data['data_de_nascimento'].toString())
                              : '---';
                          final nivelAtual = data['nivelAtual'] ?? 1;
                          final ativo = data['ativo'] == true ? 'Sim' : 'Não';
                          final email = data['e-mail'] ?? '---';
                          final sexo = data['sexo'] ?? '---';
                          final fotoUrl = data['fotoUrl'] as String?;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                                      ? NetworkImage(fotoUrl)
                                      : null,
                                  child: (fotoUrl == null || fotoUrl.isEmpty)
                                      ? const Icon(Icons.person, size: 48, color: Colors.white)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
                              const SizedBox(height: 4),
                              Text("Email: $email", style: const TextStyle(color: Colors.black)),
                              Text("Sexo: $sexo", style: const TextStyle(color: Colors.black)),
                              Text("Data de Nascimento: $dataAniversario", style: const TextStyle(color: Colors.black)),
                              Text("Ativo: $ativo", style: const TextStyle(color: Colors.black)),
                              Text("Nível Atual: $nivelAtual", style: const TextStyle(color: Colors.black)),
                              const SizedBox(height: 10),
                              const Divider(thickness: 2, color: Colors.black),
                              const Center(
                                child: Text(
                                  "Histórico de Jogos",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                ),
                              ),
                              const Divider(thickness: 2, color: Colors.black),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4B5F8B),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('usuarios')
                                        .doc(pacienteId)
                                        .collection('History_Games')
                                        .orderBy('dataJogo', descending: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      final jogos = snapshot.data!.docs;

                                      if (jogos.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("Sem jogos registados.", style: TextStyle(color: Colors.white)),
                                        );
                                      }

                                      return ListView.builder(
                                        itemCount: jogos.length,
                                        itemBuilder: (context, index) {
                                          final jogo = jogos[index].data() as Map<String, dynamic>;
                                          final nivel = jogo['nivel']?.toString() ?? '---';
                                          final tempo = jogo['duracao'] ?? '---';
                                          final data = jogo['dataJogo'] != null
                                              ? (jogo['dataJogo'] as Timestamp).toDate().toLocal().toString().substring(0, 19)
                                              : '---';
                                          final apagado = jogo['apagado'] == true;
                                          final passou = jogo['passou'] == true;

                                          Color? bgColor;
                                          Color? textColor = Colors.black;
                                          if (apagado) {
                                            bgColor = Colors.red[200];
                                            textColor = Colors.red[900];
                                          } else if (passou) {
                                            bgColor = Colors.green[200];
                                            textColor = Colors.green[900];
                                          } else {
                                            bgColor = Colors.red[100];
                                            textColor = Colors.red[900];
                                          }

                                          return Container(
                                            margin: const EdgeInsets.symmetric(vertical: 5),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: bgColor,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(16),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => GameHistoryDetailPage(jogo: jogo),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.extension, size: 24, color: Colors.black),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Jogo Torre de Hanoi: Nível $nivel",
                                                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                                        ),
                                                        Text("Data: $data", style: TextStyle(fontSize: 12, color: textColor)),
                                                        Text("Duração: $tempo", style: TextStyle(fontSize: 12, color: textColor)),
                                                      ],
                                                    ),
                                                  ),
                                                  const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => _getNivelPage(nivelAtual, pacienteId),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                                  label: const Text("COMEÇAR JOGO", style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007BFF),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
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
