import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'sucesso_pagina.dart';
import 'falhou_pagina.dart';

class Nivel1Page extends StatefulWidget {
  final String userId;
  const Nivel1Page({super.key, required this.userId});

  @override
  State<Nivel1Page> createState() => _Nivel1PageState();
}

class _Nivel1PageState extends State<Nivel1Page> {
  late DateTime startTime;
  Timer? timer;
  int tempoGasto = 0;
  int movimentos = 0;

  String torreAtual = "A";
  final String torreCorreta = "B";
  final int tempoMaximoSegundos = 45;
  final int movimentosMaximos = 2;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        tempoGasto++;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _movimentoFeito(String torreDestino) {
    setState(() {
      movimentos++;
      torreAtual = torreDestino;
    });
  }

  Future<void> _finalizarNivel() async {
    timer?.cancel();
    final endTime = DateTime.now();
    final tempoTotal = endTime.difference(startTime).inSeconds;

    bool passou = (torreAtual == torreCorreta &&
        movimentos <= movimentosMaximos &&
        tempoTotal <= tempoMaximoSegundos);

    final pacienteRef =
    FirebaseFirestore.instance.collection('usuarios').doc(widget.userId);

    // Guarda o resultado atual
    await pacienteRef.collection('History_Games').add({
      'dataJogo': endTime,
      'nivel': 1,
      'duracao': '$tempoTotal seg',
      'tempoMaximo': '$tempoMaximoSegundos seg',
      'movimentos': movimentos,
      'maxMovimentos': movimentosMaximos,
      'passou': passou,
    });

    // Atualiza nívelAtual apenas se passou
    if (passou) {
      await pacienteRef.update({'nivelAtual': 2});
    }

    if (!mounted) return;

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

  Widget _buildTorre(String nomeTorre) {
    return DragTarget<String>(
      onAccept: (data) => _movimentoFeito(nomeTorre),
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
                  child: Container(width: 80, height: 20, color: Colors.brown)),
              Positioned(
                  bottom: 20,
                  child: Container(width: 10, height: 180, color: Colors.black)),
              if (torreAtual == nomeTorre)
                Positioned(
                  bottom: 20,
                  child: Draggable<String>(
                    data: "disco",
                    feedback: _buildDisco(),
                    childWhenDragging: Container(),
                    child: _buildDisco(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisco() {
    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int movimentosRestantes = movimentosMaximos - movimentos;
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
                            timer?.cancel();
                            Navigator.pop(context);
                          },
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "NÍVEL 1 - INICIAÇÃO GUIADA",
                              style: TextStyle(
                                color: Color(0xFF007BFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Arrasta o disco azul para a torre do meio como achares correto. "
                          "Quando achares que concluiste, carrega em FINALIZAR.",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                          width: 80,
                          child: Center(
                              child: Text("Torre A",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)))),
                      SizedBox(
                          width: 80,
                          child: Center(
                              child: Text("Torre B",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)))),
                      SizedBox(
                          width: 80,
                          child: Center(
                              child: Text("Torre C",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTorre("A"),
                      _buildTorre("B"),
                      _buildTorre("C"),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, color: Colors.black),
                      const SizedBox(width: 4),
                      Text("$tempoGasto s",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 20),
                      const Icon(Icons.directions, color: Colors.black),
                      const SizedBox(width: 4),
                      Text("$movimentos",
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Movimentos restantes: $movimentosRestantes   |   Tempo restante: $tempoRestante s",
                    style:
                    const TextStyle(fontSize: 16, color: Colors.black87),
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
