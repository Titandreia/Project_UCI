import 'package:flutter/material.dart';
import 'lista_pacientes.dart';
import 'definicoes.dart';
import 'definicoes_perfil.dart';
import 'game_page.dart';
import 'perfil_historico_jogo_pacientes.dart'; // Para histórico pessoal

class HomePage extends StatelessWidget {
  final String role;
  final String userId; // UID do utilizador atual (paciente ou profissional/admin)

  const HomePage({
    super.key,
    required this.role,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final roleLower = role.toLowerCase();

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícones no topo: todos podem aceder ao perfil e definições
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ...
                      IconButton(
                        icon: const Icon(Icons.person_outline, size: 28, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(userId: userId),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, size: 28, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 250),

                  // Botão PACIENTES
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.blueAccent),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () {
                      if (roleLower == 'paciente') {
                        // Se for paciente, vai diretamente para o seu histórico pessoal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientProfilePage(pacienteId: userId),
                          ),
                        );
                      } else {
                        // Se for profissional ou admin, vai para a lista de pacientes
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientsPage(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'PACIENTES',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Botão JOGOS (todos podem aceder)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.blueAccent),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GamePage(userId: userId)),
                      );
                    },
                    child: const Text(
                      'JOGOS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
