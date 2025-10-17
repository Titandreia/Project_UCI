import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'sucesso_pagina.dart';
import 'falhou_pagina.dart';

class Nivel2Page extends StatefulWidget {
  final String userId;
  const Nivel2Page({Key? key, required this.userId}) : super(key: key);

  @override
  State<Nivel2Page> createState() => _Nivel2PageState();
}

class _Nivel2PageState extends State<Nivel2Page> {
  late DateTime startTime;
  late Timer timer;
  int tempoGasto = 0;
  int movimentos = 0;
  bool jogoComecou = false;

  Map<String, List<String>> torreDiscos = {
    'A': ['vermelho', 'azul'],
    'B': [],
    'C': [],
  };

  final int tempoMaximoSegundos = 90;
  final int movimentosMaximos = 7;
  int erros = 0;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tempoGasto++;
        if (tempoGasto >= tempoMaximoSegundos) {
          _finalizarNivel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _movimentoFeito(String torreOrigem, String torreDestino) {
    if (!jogoComecou) {
      jogoComecou = true;
      // ⚠️ NÃO reiniciar startTime nem tempoGasto aqui
    }

    setState(() {
      List<String> origem = torreDiscos[torreOrigem]!;
      List<String> destino = torreDiscos[torreDestino]!;

      if (origem.isNotEmpty) {
        String disco = origem.removeLast();
        destino.add(disco);
        movimentos++;

        if ((torreDestino == 'B' && disco != 'vermelho') ||
            (torreDestino == 'C' && disco != 'azul')) {
          erros++;
        }

        if (movimentos >= movimentosMaximos) {
          _finalizarNivel();
        }
      }
    });
  }
  Future<void> _finalizarNivel() async {
    timer.cancel();
    final endTime = DateTime.now();
    final tempoTotal = endTime.difference(startTime).inSeconds;

    bool passou = torreDiscos['B']!.contains('vermelho') &&
        torreDiscos['C']!.contains('azul') &&
        erros <= 0 &&
        tempoTotal <= tempoMaximoSegundos;

    final pacienteRef = FirebaseFirestore.instance.collection('usuarios').doc(widget.userId);

    await pacienteRef.collection('History_Games').add({
      'dataJogo': endTime,
      'nivel': 2,
      'duracao': '$tempoTotal seg',
      'tempoMaximo': '$tempoMaximoSegundos seg',
      'movimentos': movimentos,
      'erros': erros,
      'errosMaximos': 0,
      'passou': passou,
    });

    if (passou) {
      await pacienteRef.update({'nivelAtual': 3});
    }

    if (!mounted) return;

    // 🔍 Verifica o tipo de usuário (médico ou paciente)
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
  Widget _buildTorre(String nomeTorre, {Color? corBase}) {
    List<String> discos = torreDiscos[nomeTorre]!;
    List<Widget> widgetsDiscos = [];

    for (int i = 0; i < discos.length; i++) {
      String disco = discos[i];
      widgetsDiscos.add(
        Positioned(
          bottom: 20.0 + i * 22.0,
          child: i == discos.length - 1
              ? Draggable<String>(
            data: nomeTorre,
            feedback: _buildDisco(disco),
            childWhenDragging: Container(),
            child: _buildDisco(disco),
          )
              : _buildDisco(disco),
        ),
      );
    }

    return DragTarget<String>(
      onAccept: (torreOrigem) => _movimentoFeito(torreOrigem, nomeTorre),
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
                child: Container(
                  width: 80,
                  height: 20,
                  color: corBase ?? Colors.grey,
                ),
              ),
              Positioned(
                bottom: 20,
                child: Container(width: 10, height: 180, color: Colors.black),
              ),
              ...widgetsDiscos,
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisco(String cor) {
    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        color: cor == 'vermelho' ? Colors.red : Colors.blue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int errosRestantes = 0;
    int tempoRestante = tempoMaximoSegundos - tempoGasto;

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
                          icon: const Icon(Icons.arrow_back,
                              size: 28, color: Colors.black),
                          onPressed: () {
                            timer.cancel();
                            Navigator.pop(context);
                          },
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "NÍVEL 2 - CORRESPONDÊNCIA DE CORES",
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
                      "Arrasta o disco vermelho para a torre do meio (B) e o azul para a torre da direita (C). Quando achares que concluiste, carrega em FINALIZAR.",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text("Torre A",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildTorre("A"),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Torre B",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildTorre("B", corBase: Colors.red),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Torre C",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildTorre("C", corBase: Colors.blue),
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Icon(Icons.timer,
                                    color: tempoRestante <= 15
                                        ? Colors.red
                                        : Colors.black),
                                Text("$tempoGasto s",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text("Restam: ${tempoRestante}s",
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.directions,
                                    color: Colors.black),
                                Text("$movimentos",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const Text("Movimentos",
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(Icons.warning,
                                    color: errosRestantes == 0
                                        ? Colors.red
                                        : Colors.orange),
                                Text("$erros",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text("Restam: $errosRestantes",
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _finalizarNivel,
                    icon:
                    const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text("FINALIZAR",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
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
