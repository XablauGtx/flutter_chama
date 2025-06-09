import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Imports das telas
import 'package:chama_app/screens/recados_screen.dart';
import 'package:chama_app/agenda/agenda_screen.dart';
import 'package:chama_app/screens/kits_de_voz_screen.dart';
import 'package:chama_app/screens/letras_screen.dart';
import 'package:chama_app/screens/banda_screen.dart';
import 'package:chama_app/screens/cifras_screen.dart';
import 'package:chama_app/screens/oracao_screen.dart';
import 'package:chama_app/screens/chamada_chama.dart';

// Imports dos widgets reutilizáveis
import 'package:chama_app/helpers/dialog_helpers.dart';
import 'package:chama_app/widgets/my_drawer.dart';
import 'package:chama_app/widgets/info_drawer.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void btnRecados(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecadosScreen()));
  void btnAgenda(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaScreen()));
  void btnKitVoz(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const KitsDeVozScreen()));
  void btnLetras(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const LetrasScreen()));
  void btnBanda(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const BandaScreen()));
  void btnCifras(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const CifrasScreen()));
  void btnOracao(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const OracaoScreen()));
  void btnNovoCo(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChamadaChamaScreen()));
  
  // Função para partituras chama o pop-up de senha
  void btnPartitura(BuildContext context) => showPasswordDialog(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),      // Menu principal à esquerda
      endDrawer: const InfoDrawer(), // <<<--- NOVO MENU DE INFO À DIREITA
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Chama Coral',
          style: TextStyle(
            fontFamily: 'Nexa',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            onPressed: () {},
          ),
          // --- BOTÃO DE INFORMAÇÕES ATUALIZADO ---
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 26),
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // <<<--- ABRE O NOVO MENU
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/wallpaper.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Image.asset(
                'assets/images/chama_coral.png',
                width: 900,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                const Spacer(flex: 30),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    buildButton(label: "Recados", assetPath: 'assets/images/recado.svg', onPressed: () => btnRecados(context), isSvg: true),
                    buildButton(label: "Agenda", assetPath: 'assets/images/agenda.svg', onPressed: () => btnAgenda(context), isSvg: true),
                    buildButton(label: "Kits de Voz", assetPath: 'assets/images/kits_de_voz.svg', onPressed: () => btnKitVoz(context), isSvg: true),
                    buildButton(label: "Letras", assetPath: 'assets/images/letras.svg', onPressed: () => btnLetras(context), isSvg: true),
                    buildButton(label: "Banda", assetPath: 'assets/images/banda.svg', onPressed: () => btnBanda(context), isSvg: true),
                    buildButton(label: "Partituras", assetPath: 'assets/images/partitura.svg', onPressed: () => btnPartitura(context), fontSize: 11, isSvg: true),
                    buildButton(label: "Cifras", assetPath: 'assets/images/cifra.svg', onPressed: () => btnCifras(context), isSvg: true),
                    buildButton(label: "Oração", assetPath: 'assets/images/oracao.svg', onPressed: () => btnOracao(context), fontSize: 12, isSvg: true),
                    buildButton(label: "Novo Coralista", assetPath: 'assets/images/novo_usuario.svg', onPressed: () => btnNovoCo(context), fontSize: 12, isSvg: true),
                  ],
                ),
                const Spacer(flex: 1),
                Image.asset('assets/images/nao_se_apague.png', width: 150),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
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
                    color: const Color(0xFFF44336),
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
