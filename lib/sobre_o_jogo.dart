import 'package:flutter/material.dart';
import 'game_page.dart';

class AboutGamePage extends StatelessWidget {
  final String userId;

  const AboutGamePage({super.key, required this.userId});

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
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
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
                              "SOBRE O JOGO",
                              style: TextStyle(
                                color: Color(0xFF007BFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        border: Border.all(color: const Color(0xFF94A8CE), width: 3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                "TORRE DE HANOI",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "O jogo Torre de Hanoi é um clássico de resolução de problemas e raciocínio lógico, onde o objetivo é mover discos de tamanhos diferentes entre três torres, respeitando regras simples mas desafiadoras.",
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "NÍVEIS DO JOGO:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "• Nível 1: Iniciação Guiada\n"
                                  "  Aprender a arrastar o disco azul para a torre central — sem regras complexas. Foi o primeiro contacto com o movimento.\n\n"
                                  "• Nível 2: Correspondência de Cores\n"
                                  "  Leva os discos à torre da respectiva cor: vermelho para B, azul para C. Estimula atenção visual e memória.\n\n"
                                  "• Nível 3: Reconstruir Hierarquia\n"
                                  "  Os discos estao distribuídos um em cada torre.Organiza-os na torre B, do maior (verde) em baixo ao menor (vermelho) em cima.\n\n"
                                  "• Nível 4: Planeamento Sequencial\n"
                                  "  Move todos os discos da torre A para a torre C, mantendo a ordem. Planeia os passos antes de executar.",
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.justify,
                            ),

                            const SizedBox(height: 20),
                            const Text(
                              "Este jogo é ideal para desenvolver competências cognitivas de forma progressiva, aumentando gradualmente a complexidade e o desafio. Boa sorte!",
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 40),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GamePage(userId: userId),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                ),
                                child: const Text(
                                  "FECHAR",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
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
}
