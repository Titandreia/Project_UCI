import 'package:flutter/material.dart';

class QuestionsPage extends StatelessWidget {
  const QuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com imagem
          Positioned.fill(
            child: Image.asset(
              'assets/images/Image_1.png', // Atualiza para o teu caminho correto
              fit: BoxFit.cover,
            ),
          ),

          // Conteúdo principal
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Barra branca no topo com seta e título azul
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'QUESTÕES FREQUENTES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF007BFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lista de cartões de pergunta e resposta
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      children: [
                        _qaCard(
                          "OS MEUS DADOS ESTÃO SEGUROS?",
                          "Sim, os seus dados estão seguros. A aplicação utiliza encriptação e sistemas de autenticação seguros para proteger a sua privacidade e manter toda a informação sensível confidencial.",
                        ),
                        _qaCard(
                          "COMO POSSO CRIAR UMA CONTA NA MINDREVIVE?",
                          "Para criar uma conta, basta clicar na opção 'Criar Conta' e seguir os passos para inserir as suas informações pessoais.",
                        ),
                        _qaCard(
                          "A APLICAÇÃO ESTÁ DISPONÍVEL NOUTROS IDIOMAS?",
                          "Sim, por agora a aplicação está disponível em inglês e português.",
                        ),
                        _qaCard(
                          "O QUE DEVO FAZER SE ESQUECER A MINHA PALAVRA-PASSE?",
                          "Se se esquecer da palavra-passe, clique primeiro na opção 'Esqueceu-se da palavra-passe'. Será então redirecionado para uma página onde poderá introduzir o seu endereço de e-mail, e uma nova palavra-passe ser-lhe-á enviada.",
                        ),
                        _qaCard(
                          "POSSO ELIMINAR A MINHA CONTA?",
                          "Sim, pode eliminar a sua conta. Basta aceder às definições e selecionar a opção 'Eliminar Conta'.",
                        ),
                      ],
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

  // Widget auxiliar para cartão de pergunta e resposta
  Widget _qaCard(String pergunta, String resposta) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF94A8CE), width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pergunta,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 12),
          Text(
            resposta,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
