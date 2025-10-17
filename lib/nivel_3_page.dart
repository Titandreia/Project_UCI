import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'sucesso_pagina.dart';
import 'falhou_pagina.dart';

class Nivel3Page extends StatefulWidget {
  final String userId;
  const Nivel3Page({super.key, required this.userId});

  @override
  State<Nivel3Page> createState() => _Nivel3PageState();
}

class _Nivel3PageState extends State<Nivel3Page> {
  late DateTime startTime;
  late Timer timer;
  int tempoGasto = 0;
  int movimentos = 0;
  bool jogoComecou = false;

  List<String> torreA = ['verde'];     // Aleatório
  List<String> torreB = ['vermelho'];  // Aleatório
  List<String> torreC = ['azul'];      // Aleatório

  final int tempoMaximoSegundos = 120;
  final int movimentosMaximos = 7;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tempoGasto++;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _moverDisco(String origem, String destino) {
    if (!jogoComecou) {
      jogoComecou = true;
      // ⚠️ Não reiniciar tempoGasto nem startTime aqui
    }

    List<String> origemLista = _getTorre(origem);
    List<String> destinoLista = _getTorre(destino);

    if (origemLista.isNotEmpty) {
      String disco = origemLista.last;

      if (destinoLista.isEmpty || _getTamanho(disco) < _getTamanho(destinoLista.last)) {
        setState(() {
          origemLista.removeLast();
          destinoLista.add(disco);
          movimentos++;
        });
      }
    }
  }
  List<String> _getTorre(String nome) {
    switch (nome) {
      case 'A':
        return torreA;
      case 'B':
        return torreB;
      case 'C':
        return torreC;
      default:
        return [];
    }
  }

  int _getTamanho(String cor) {
    switch (cor) {
      case 'vermelho':
        return 1;
      case 'azul':
        return 2;
      case 'verde':
        return 3;
      default:
        return 0;
    }
  }

  bool _verificarHierarquiaFinal() {
    return torreB.length == 3 &&
        torreA.isEmpty &&
        torreC.isEmpty &&
        torreB[0] == 'verde' &&
        torreB[1] == 'azul' &&
        torreB[2] == 'vermelho';
  }

  Future<void> _finalizarNivel() async {
    timer.cancel();
    final endTime = DateTime.now();
    final tempoTotal = endTime.difference(startTime).inSeconds;

    bool passou = _verificarHierarquiaFinal() &&
        tempoTotal <= tempoMaximoSegundos &&
        movimentos <= movimentosMaximos;

    final pacienteRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.userId);

    await pacienteRef.collection('History_Games').add({
      'dataJogo': endTime,
      'nivel': 3,
      'duracao': '$tempoTotal seg',
      'tempoMaximo': '$tempoMaximoSegundos seg',
      'movimentos': movimentos,
      'movimentosMaximos': movimentosMaximos,
      'passou': passou,
    });

    if (passou) {
      await pacienteRef.update({'nivelAtual': 4});
    }

    if (!mounted) return;

    // 🔍 Verifica se o usuário é médico
    final userSnapshot = await pacienteRef.get();
    final role = userSnapshot.data()?['role'] ?? 'paciente';
    final isMedico = role == 'admin' || role == 'profissional';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => passou
            ? SuccessPage(userId: widget.userId, isMedico: isMedico)
            : FailPage(usuarioId: widget.userId, isMedico: isMedico),
      ),
    );
  }


  Widget _buildTorre(String nome, List<String> discos) {
    return DragTarget<String>(
      onAccept: (origem) => _moverDisco(origem, nome),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 80,
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 0,
                child: Container(width: 80, height: 20, color: Colors.grey),
              ),
              Positioned(
                bottom: 20,
                child: Container(width: 10, height: 180, color: Colors.black),
              ),
              for (int i = 0; i < discos.length; i++)
                Positioned(
                  bottom: 20.0 + i * 22,
                  child: Draggable<String>(
                    data: nome,
                    feedback: _buildDisco(discos[i]),
                    childWhenDragging: Container(),
                    child: _buildDisco(discos[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisco(String cor) {
    Color color;
    double width;

    switch (cor) {
      case 'vermelho':
        color = Colors.red;
        width = 40;
        break;
      case 'azul':
        color = Colors.blue;
        width = 55;
        break;
      case 'verde':
        color = Colors.green;
        width = 70;
        break;
      default:
        color = Colors.grey;
        width = 40;
    }

    return Container(
      width: width,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int tempoRestante = tempoMaximoSegundos - tempoGasto;
    int movimentosRestantes = movimentosMaximos - movimentos;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Image_1.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
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
                          onPressed: () {
                            timer.cancel();
                            Navigator.pop(context);
                          },
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "NÍVEL 3 - RECONSTRUIR",
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
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Organiza os discos na TORRE B, começando pelo maior (verde) em baixo e terminando com o menor (vermelho) em cima. Usa a lógica e atenção à ordem!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text("Torre A", style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildTorre("A", torreA),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Torre B", style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildTorre("B", torreB),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Torre C", style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildTorre("C", torreC),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.timer, color: tempoRestante <= 20 ? Colors.red : Colors.black),
                            Text("$tempoGasto s", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Restam: ${tempoRestante}s", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.directions),
                            Text("$movimentos", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Restam: $movimentosRestantes", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _finalizarNivel,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text("FINALIZAR", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

