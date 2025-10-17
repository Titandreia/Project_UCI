import 'package:flutter/material.dart';
import 'selecao_nivel_jogo.dart';

class CognitiveAssessmentPage extends StatefulWidget {
  final String userId;

  const CognitiveAssessmentPage({super.key, required this.userId});

  @override
  State<CognitiveAssessmentPage> createState() => _CognitiveAssessmentPageState();
}

class _CognitiveAssessmentPageState extends State<CognitiveAssessmentPage> {
  final List<String> perguntas = [
    "O paciente consegue manter a atenção durante alguns segundos?",
    "O paciente reconhece pessoas próximas?",
    "O paciente consegue seguir instruções simples sem precisar de repetição constante?",
    "O paciente apresenta sinais de desorientação ou confusão frequente?",
    "O paciente consegue comunicar as suas necessidades básicas (ex:dor,sede,fome)?",
  ];

  Map<int, bool?> respostas = {};

  @override
  void initState() {
    super.initState();
    // Inicializa o mapa de respostas
    respostas = {for (var i = 1; i <= perguntas.length; i++) i: null};
  }

  void _submeterRespostas() {
    // Verifica se todas as perguntas foram respondidas
    if (respostas.values.any((r) => r == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, responda a todas as perguntas.")),
      );
      return;
    }

    // Envia para a LoadingPage para calcular o nível e redirecionar
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingPage(
          userId: widget.userId,
          respostas: respostas.map((k, v) => MapEntry(k, v!)),
        ),
      ),
    );
  }

  Widget _buildPergunta(String texto, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texto,
          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text("SIM", style: TextStyle(color: Colors.black)),
                value: true,
                groupValue: respostas[index],
                onChanged: (valor) {
                  setState(() {
                    respostas[index] = valor;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text("NÃO", style: TextStyle(color: Colors.black)),
                value: false,
                groupValue: respostas[index],
                onChanged: (valor) {
                  setState(() {
                    respostas[index] = valor;
                  });
                },
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset('assets/images/Image_1.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Barra superior com botão voltar e título
                  Container(
                    color: Colors.white.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "AVALIAÇÃO COGNITIVA",
                              style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Perguntas
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        border: Border.all(color: const Color(0xFF94A8CE), width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            perguntas.length,
                                (index) => _buildPergunta(perguntas[index], index + 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Botão DONE
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _submeterRespostas,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text("DONE", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

