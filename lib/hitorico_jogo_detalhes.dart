import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameHistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> jogo;

  const GameHistoryDetailPage({super.key, required this.jogo});

  @override
  Widget build(BuildContext context) {
    final nivel = jogo['nivel']?.toString() ?? '---';
    final data = jogo['dataJogo'] != null
        ? (jogo['dataJogo'] as Timestamp).toDate().toLocal().toString().substring(0, 19)
        : '---';
    final duracao = jogo['duracao']?.toString() ?? '---';
    final erros = jogo['erros']?.toString() ?? '---';
    final errosMaximos = jogo['errosMaximos']?.toString() ?? '---';
    final movimentos = jogo['movimentos']?.toString() ?? '---';
    final maxMovimentos = jogo['maxMovimentos']?.toString() ?? '---';
    final tempoMaximo = jogo['tempoMaximo']?.toString() ?? '---';
    final passou = jogo.containsKey('passou')
        ? (jogo['passou'] == true ? "Sim" : (jogo['passou'] == false ? "Não" : '---'))
        : '---';

    final List<MapEntry<String, String>> detalhes = [
      MapEntry("Nível", nivel),
      MapEntry("Data do Jogo", data),
      MapEntry("Duração", duracao),
      MapEntry("Erros", erros),
      MapEntry("Erros Máximos", errosMaximos),
      MapEntry("Movimentos Feitos", movimentos),
      MapEntry("Máximo de Movimentos", maxMovimentos),
      MapEntry("Tempo Máximo", tempoMaximo),
      MapEntry("Passou", passou),
    ];

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
            child: Column(
              children: [
                Container(
                  color: Colors.white.withOpacity(0.95),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'DETALHES DO JOGO',
                            style: TextStyle(
                              color: Color(0xFF007BFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          border: Border.all(color: const Color(0xFF94A8CE), width: 3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Jogo Torre de Hanoi: Nível $nivel",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Divider(thickness: 2, color: Color(0xFF94A8CE)),
                            ...detalhes.map((entry) => _infoRow(entry.key, entry.value)).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: value == '---' ? Colors.grey : Colors.black87,
              fontStyle: value == '---' ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}