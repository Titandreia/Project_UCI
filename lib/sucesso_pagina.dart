import 'package:flutter/material.dart';
import 'lista_pacientes.dart';
import 'perfil_historico_jogo_pacientes.dart';

class SuccessPage extends StatelessWidget {
  final String userId;
  final bool isMedico;

  const SuccessPage({
    super.key,
    required this.userId,
    required this.isMedico,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo comum
          Positioned.fill(
            child: Image.asset(
              'assets/images/Image_1.png',
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
                    "BOA! SUBISTE DE NÍVEL",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),

                  const SizedBox(height: 100),

                  // Imagem de sucesso
                  Image.asset(
                    'assets/images/sucess_1.png',
                    height: 300,
                  ),

                  const SizedBox(height: 100),

                  // Texto motivacional
                  const Text(
                    "ESTÁS A EVOLUIR, CONTINUA ASSIM!",
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
                            builder: (_) => PatientProfilePage(pacienteId: userId),
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

