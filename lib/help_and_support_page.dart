import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 👉 Fundo com imagem
          Positioned.fill(
            child: Image.asset(
              'assets/images/Image_1.png', // Atualiza para o teu caminho correto
              fit: BoxFit.cover,
            ),
          ),

          // 👉 Conteúdo principal
          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 👉 SESSÃO BRANCA NO TOPO com seta e título azul
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    color: Colors.white, // Fundo branco
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, size: 28, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AJUDA E SUPORTE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF007BFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(width: 48), // Espaço para equilibrar visualmente
                      ],
                    ),
                  ),

                  SizedBox(height: 200),

                  // 👉 Cartão central, agora mais acima e com melhorias visuais e funcionais
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFF94A8CE), width: 3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 👉 Título adicional na caixa
                        Text(
                          "Contacta-nos",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),

                        Icon(Icons.notifications, size: 48, color: Colors.black),
                        SizedBox(height: 16),

                        Text(
                          "Descreva o seu problema num e-mail para este endereço:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),

                        // 👉 Linha com e-mail e botão de cópia
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // E-mail selecionável
                            SelectableText(
                              "mindrevive.support@gmail.com",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            // Botão de cópia
                            IconButton(
                              icon: Icon(Icons.copy, size: 20, color: Colors.black),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: "mindrevive.support@gmail.com"),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("E-mail copiado para a área de transferência"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(child: SizedBox()), // Empurra o conteúdo para cima
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
