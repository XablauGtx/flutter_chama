import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';

import 'package:chama_app/widgets/app_scaffold.dart';

// --- TELA DE DETALHES ATUALIZADA ---
class RecadoDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final DateTime date; // Recebe a data do recado

  const RecadoDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Recado",
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // Card amarelo para o conteúdo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD15B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: -10,
                    child: Icon(Icons.format_quote, size: 50, color: Colors.black.withOpacity(0.1)),
                  ),
                  Positioned(
                    bottom: -40,
                    right: -10,
                    child: Icon(Icons.format_quote, size: 50, color: Colors.black.withOpacity(0.1)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, // Título dentro do card
                        style: const TextStyle(
                          color: Color(0xFF3D3D3D),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nexa'
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content,
                        style: const TextStyle(
                          color: Color(0xFF3D3D3D),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        // Usa a data recebida do Firestore
                        DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(date),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MODELO E TELA PRINCIPAL DE RECADOS ---
class Recado {
  final String title;
  final String content;
  final String imageUrl;
  final DateTime date; // Adicionado o campo de data

  Recado({required this.title, required this.content, required this.imageUrl, required this.date});
}

class RecadosScreen extends StatefulWidget {
  const RecadosScreen({super.key});

  @override
  State<RecadosScreen> createState() => _RecadosScreenState();
}

class _RecadosScreenState extends State<RecadosScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Recados",
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recados').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum recado no momento.", style: TextStyle(color: Colors.white)));
          }

          final recados = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp?;
            return Recado(
              title: data['titulo'] ?? '',
              content: data['conteudo'] ?? '',
              imageUrl: data['imagemUrl'] ?? '',
              date: timestamp?.toDate() ?? DateTime.now(), // Lê a data do recado
            );
          }).toList();

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: recados.length,
                itemBuilder: (context, index) {
                  final recado = recados[index];
                  return _buildRecadoPage(recado);
                },
              ),
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: recados.length,
                    effect: const WormEffect(
                      dotColor: Colors.white54,
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecadoPage(Recado recado) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: recado.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[800]),
            errorWidget: (context, url, error) => Container(color: Colors.black, child: const Icon(Icons.error, color: Colors.red)),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.8), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recado.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nexa',
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecadoDetailScreen(
                          title: recado.title,
                          content: recado.content,
                          date: recado.date, // Passa a data correta para a tela de detalhes
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.arrow_forward, color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
