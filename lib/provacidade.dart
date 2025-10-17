import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key}); // `const` para otimizar e indicar que é imutável

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
                children: [
                  // 👉 Barra branca no topo com seta e título azul
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
                            'PRIVACIDADE',
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

                  // 👉 Lista de cartões de privacidade
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      children: [
                        _privacyCard(
                          "DADOS RECOLHIDOS E OBJECTIVO",
                          "Recolhemos dados pessoais (por exemplo, nome, e-mail) para melhorar a sua experiência, fornecer apoio, enviar notificações e personalizar o conteúdo, tudo com o seu consentimento e exclusivamente para esses fins.",
                        ),
                        _privacyCard(
                          "PARTILHA DE DADOS COM TERCEIROS",
                          "Podemos partilhar dados com parceiros e prestadores de serviços (por exemplo, fornecedores de e-mail para notificações) para melhorar a sua experiência e apoio. Todos os terceiros cumprem rigorosos padrões de segurança e privacidade.",
                        ),
                        _privacyCard(
                          "DIREITOS DO UTILIZADOR",
                          "Tem o direito de aceder, corrigir, eliminar, limitar o uso ou solicitar uma cópia dos seus dados. Contacte-nos para exercer esses direitos.",
                        ),
                        _privacyCard(
                          "SEGURANÇA DOS DADOS",
                          "Utilizamos encriptação de dados, controlos de acesso e monitorização contínua para proteger a sua informação contra acessos não autorizados e violações.",
                        ),
                        _privacyCard(
                          "CONTACTO PARA DÚVIDAS SOBRE PRIVACIDADE",
                          "Para questões de privacidade ou para exercer os seus direitos, entre em contacto connosco através do e-mail:\n\nmind_revive_privacy@gmail.com",
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

  // 👉 Widget auxiliar para criar um cartão de privacidade com estilo branco e borda azul
  Widget _privacyCard(String titulo, String conteudo) {
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
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            conteudo,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
