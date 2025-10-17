import 'package:flutter/material.dart';
import 'lista_pacientes.dart';
import 'perfil_historico_jogo_pacientes.dart';

class FailPage extends StatelessWidget {
  final String usuarioId;
  final bool isMedico;

  const FailPage({super.key, required this.usuarioId, required this.isMedico});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo
          Positioned.fill(
            child: Image.asset(
              'assets/images/Image_1.png', // mesmo fundo da SuccessPage
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Botão voltar
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Título
                  const Text(
                    "NÃO CONSEGUISTE CONCLUIR",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),

                  const SizedBox(height: 100),

                  // Imagem de falha
                  Image.asset(
                    'assets/images/fail_1.png',
                    height: 300,
                  ),

                  const SizedBox(height: 100),

                  // Texto de apoio
                  const Text(
                    "NÃO DESISTAS, PODES TENTAR OUTRA VEZ!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),

                  const Spacer(),

                  // Botão histórico
                  ElevatedButton.icon(
                    onPressed: () {
                      if (isMedico) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PatientsPage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientProfilePage(pacienteId: usuarioId),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.history, color: Colors.white),
                    label: const Text("HISTÓRICO"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
