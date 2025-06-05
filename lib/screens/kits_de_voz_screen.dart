import 'package:flutter/material.dart';
import 'package:chama_app/screens/kitvoz/quatro_vozes.dart';
import 'package:chama_app/screens/kitvoz/quatro_vozes_acapella.dart';
import 'package:chama_app/screens/kitvoz/sopranos.dart';
import 'package:chama_app/screens/kitvoz/contralto.dart';
import 'package:chama_app/screens/kitvoz/tenores.dart';
import 'package:chama_app/screens/kitvoz/baixos.dart';
import 'package:chama_app/widgets/app_scaffold.dart'; // <<<--- IMPORT DO NOSSO AppScaffold

class KitsDeVozScreen extends StatelessWidget {
  const KitsDeVozScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- A TELA AGORA USA O AppScaffold ---
    return AppScaffold(
      title: 'Chama Coral', // Título que será exibido no AppBar do AppScaffold
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'), // Seu wallpaper de fundo
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          children: [
            buildNaipeCard(
              context,
              '4 vozes',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuatroVozesScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              '4 vozes acapella',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuatroVozesAcapellaScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Sopranos',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SopranoScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Contraltos',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContraltoScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Tenores',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TenoresScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Baixos',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BaixoScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir cada cartão de naipe (continua igual)
  Widget buildNaipeCard(BuildContext context, String label, IconData iconData, VoidCallback? onPressed) {
    return Card(
      color: const Color(0xFF192F3C), // Cor de fundo do cartão
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bordas arredondadas
      ),
      child: InkWell( // Permite que o cartão seja clicável
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
          child: Row(
            children: [
              const Icon(Icons.music_note, color: Colors.red, size: 40), // Placeholder de ícone
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Nexa',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                iconData, // Ícone da câmera
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}