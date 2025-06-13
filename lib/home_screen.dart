import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

// ignore: unused_import
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chama_app/agenda/agenda_screen.dart';
import 'package:chama_app/data/bible_verses.dart';
import 'package:chama_app/helpers/dialog_helpers.dart';
import 'package:chama_app/screens/banda_screen.dart';
import 'package:chama_app/screens/chamada_chama.dart';
import 'package:chama_app/screens/cifras_screen.dart';
import 'package:chama_app/screens/kits_de_voz_screen.dart';
import 'package:chama_app/screens/letras_screen.dart';
import 'package:chama_app/screens/oracao_screen.dart';
import 'package:chama_app/screens/recados_screen.dart';
import 'package:chama_app/screens/settings_screen.dart';
import 'package:chama_app/widgets/info_drawer.dart';
import 'package:chama_app/widgets/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _carouselIndex = 0;
  late final Stream<QuerySnapshot> _carouselStream;
  late final Map<String, String> _verseOfTheDay;

  // Chave global para identificar o widget que queremos "fotografar"
  final GlobalKey _verseArtKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _carouselStream = FirebaseFirestore.instance.collection('carrossel').orderBy('ordem').snapshots();
    _selectVerseOfTheDay();
  }

  void _selectVerseOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final verseIndex = dayOfYear % bibleVerses.length;
    _verseOfTheDay = bibleVerses[verseIndex];
  }

  /// Gera e partilha o versículo como uma imagem.
  Future<void> _shareVerseAsImage(Map<String, String> verse) async {
    try {
      // 1. Acede ao RenderObject do widget que queremos converter
      final RenderRepaintBoundary boundary = _verseArtKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // 2. Converte o RenderObject numa imagem com maior resolução
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 3. Guarda a imagem num ficheiro temporário
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/versiculo_do_dia.png').create();
      await file.writeAsBytes(pngBytes);

      // 4. Usa o share_plus para partilhar o ficheiro da imagem
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'Versículo do Dia - Chama Coral');

    } catch (e) {
      print("Erro ao gerar ou partilhar imagem: $e");
      // Se algo falhar, partilha como texto simples como fallback
      final textToShare = '"${verse['text']}"\n- ${verse['reference']}';
      await Share.share(textToShare, subject: 'Versículo do Dia');
    }
  }

  // Funções de navegação
  void btnRecados() => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecadosScreen()));
  void btnAgenda() => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaScreen()));
  void btnKitVoz() => Navigator.push(context, MaterialPageRoute(builder: (context) => const KitsDeVozScreen()));
  void btnLetras() => Navigator.push(context, MaterialPageRoute(builder: (context) => const LetrasScreen()));
  void btnBanda() => Navigator.push(context, MaterialPageRoute(builder: (context) => const BandaScreen()));
  void btnCifras() => Navigator.push(context, MaterialPageRoute(builder: (context) => const CifrasScreen()));
  void btnOracao() => Navigator.push(context, MaterialPageRoute(builder: (context) => const OracaoScreen()));
  void btnChamada() => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChamadaChamaScreen()));
  void btnPartitura() => showPasswordDialog(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      endDrawer: const InfoDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Chama Coral', style: TextStyle(fontFamily: 'Nexa', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 26),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // A imagem de fundo
          Positioned.fill(
            child: Image.asset('assets/images/wallpaper.png', fit: BoxFit.cover),
          ),
          
          // O widget da arte que será fotografado. Fica escondido fora do ecrã.
          Transform.translate(
            offset: const Offset(-5000, -5000), // Põe o widget fora da área visível
            child: RepaintBoundary(
              key: _verseArtKey,
              child: SizedBox(
                width: 1080, // Tamanho padrão para Stories
                height: 1920,
                child: VerseArtWidget(verse: _verseOfTheDay),
              ),
            ),
          ),
          
          // O conteúdo principal da sua tela
          SafeArea(
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _carouselStream,
                  builder: (context, snapshot) {
                    final List<Widget> carouselItems = [];

                    // Adiciona o slide do versículo primeiro
                    carouselItems.add(_buildVerseSlide(_verseOfTheDay));

                    // Adiciona as imagens do carrossel do Firebase
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final images = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final url = data['imagemUrl'] as String?;
                        if (url != null && url.isNotEmpty) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(color: Colors.grey[850]),
                              errorWidget: (context, url, error) => Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                            ),
                          );
                        }
                        return null;
                      }).whereType<Widget>().toList();
                      carouselItems.addAll(images);
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                        carouselItems.add(const Center(child: CircularProgressIndicator()));
                    }

                    return Column(
                      children: [
                         const SizedBox(height: 5.0), // <-- ADICIONE ESTA LINHA
                        CarouselSlider(
                          items: carouselItems,
                          options: CarouselOptions(
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 30),
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.9,
                            onPageChanged: (index, reason) {
                              setState(() { _carouselIndex = index; });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSmoothIndicator(
                          activeIndex: _carouselIndex,
                          count: carouselItems.length,
                          effect: const WormEffect(
                            dotColor: Colors.white54,
                            activeDotColor: Colors.red,
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          buildButton(label: "Recados", assetPath: 'assets/images/recado.svg', onPressed: btnRecados, isSvg: true),
                          buildButton(label: "Agenda", assetPath: 'assets/images/agenda.svg', onPressed: btnAgenda, isSvg: true),
                          buildButton(label: "Kits de Voz", assetPath: 'assets/images/kits_de_voz.svg', onPressed: btnKitVoz, isSvg: true),
                          buildButton(label: "Letras", assetPath: 'assets/images/letras.svg', onPressed: btnLetras, isSvg: true),
                          buildButton(label: "Banda", assetPath: 'assets/images/banda.svg', onPressed: btnBanda, isSvg: true),
                          buildButton(label: "Partituras", assetPath: 'assets/images/partitura.svg', onPressed: btnPartitura, fontSize: 11, isSvg: true),
                          buildButton(label: "Cifras", assetPath: 'assets/images/cifra.svg', onPressed: btnCifras, isSvg: true),
                          buildButton(label: "Pedidos de\nOração", assetPath: 'assets/images/oracao.svg', onPressed: btnOracao, fontSize: 12, isSvg: true),
                          buildButton(label: "Chamada", assetPath: 'assets/images/novo_usuario.svg', onPressed: btnChamada, fontSize: 12, isSvg: true),
                        ],
                      ),
                    ),
                  ),
                ),
                Image.asset('assets/images/nao_se_apague.png', width: 150),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseSlide(Map<String, String> verse) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              'assets/images/chama_coral.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '"${verse['text']}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                verse['reference']!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nexa'
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Partilhar Versículo como Imagem',
            onPressed: () => _shareVerseAsImage(verse),
          ),
        ),
      ],
    );
  }

  Widget buildButton({
    required String label,
    required String assetPath,
    required VoidCallback onPressed,
    double fontSize = 15,
    bool isSvg = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 118,
        height: 124,
        decoration: BoxDecoration(
          color: const Color(0xFF192F3C),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSvg
                ? SvgPicture.asset(
                    assetPath,
                    height: 48,
                    colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                  )
                : Image.asset(
                    assetPath,
                    height: 48,
                    color: Colors.red,
                  ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nexa',
                color: Colors.white,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NOVO WIDGET ---
class VerseArtWidget extends StatelessWidget {
  final Map<String, String> verse;
  const VerseArtWidget({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/template_partilha.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '"${verse['text']}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 30,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      shadows: [Shadow(blurRadius: 10.0, color: Colors.black87, offset: Offset(2, 2))],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    verse['reference']!,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
