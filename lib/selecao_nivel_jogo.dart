import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uci_project/nivel_1_page.dart';
import 'package:uci_project/nivel_2_page.dart';
import 'package:uci_project/nivel_3_page.dart';
import 'package:uci_project/nivel_4_page.dart';

class LoadingPage extends StatefulWidget {
  final Map<int, bool> respostas;
  final String userId;

  const LoadingPage({
    super.key,
    required this.respostas,
    required this.userId,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  int nivelAtual = 1;

  @override
  void initState() {
    super.initState();
    _iniciarProcessamento();
  }

  Future<void> _iniciarProcessamento() async {
    // Anima o progresso visual
    for (int i = 2; i <= 4; i++) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        nivelAtual = i;
      });
    }

    // Calcula o nível a partir das respostas
    int nivelCalculado = _calcularNivel(widget.respostas);

    final pacienteRef = FirebaseFirestore.instance.collection('usuarios').doc(widget.userId);

    // Atualiza ou cria o documento do paciente (usando merge: true!)
    await pacienteRef.set({
      'nivelAtual': nivelCalculado,
    }, SetOptions(merge: true));

    // Grava as respostas na subcoleção "avaliacao_inicial"
    for (int i = 1; i <= 5; i++) {
      await pacienteRef.collection('avaliacao_inicial').doc('questao_$i').set({
        'questionId': 'questao_$i',
        'answer': widget.respostas[i],
      });
    }

    // Vai para a página correta do nível
    Widget proximoNivel;
    switch (nivelCalculado) {
      case 1:
        proximoNivel = Nivel1Page(userId: widget.userId);
        break;
      case 2:
        proximoNivel = Nivel2Page(userId: widget.userId);
        break;
      case 3:
        proximoNivel = Nivel3Page(userId: widget.userId);
        break;
      case 4:
        proximoNivel = Nivel4Page(userId: widget.userId);
        break;
      default:
        proximoNivel = Nivel1Page(userId: widget.userId);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => proximoNivel),
      );
    }
  }

  int _calcularNivel(Map<int, bool> respostas) {
    int totalSim = respostas.values.where((v) => v == true).length;
    if (totalSim <= 1) return 1;
    if (totalSim == 2) return 2;
    if (totalSim == 3) return 3;
    return 4; // 4 ou 5 SIMs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/Image_1.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "A IDENTIFICAR O SEU NÍVEL...",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Image.asset('assets/images/loading_1.png', height: 350),
                ),
                const SizedBox(height: 80),
                Text(
                  "A PROCESSAR $nivelAtual DE 4 NÍVEIS...",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: LinearProgressIndicator(
                    color: Colors.green,
                    backgroundColor: Colors.white,
                    value: nivelAtual / 4,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "A ANALISAR AS RESPOSTAS...",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

