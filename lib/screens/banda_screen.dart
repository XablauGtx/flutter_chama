import 'package:flutter/material.dart';
import 'package:chama_app/agenda/agenda_banda_screen.dart';
import 'package:chama_app/screens/banda/Piano.dart';
import 'package:chama_app/screens/banda/Baixo.dart';
import 'package:chama_app/screens/banda/Bateria.dart';
import 'package:chama_app/screens/banda/Guitarra_1.dart';
import 'package:chama_app/screens/banda/Guitarra_2.dart';
import 'package:chama_app/screens/banda/Harmond.dart';
import 'package:chama_app/screens/banda/MusicasCompletas.dart';
import 'package:chama_app/screens/banda/Strings.dart';
import 'package:chama_app/screens/banda/Violao.dart';
import 'package:chama_app/widgets/app_scaffold.dart'; // <<<--- IMPORT DO NOSSO AppScaffold

class BandaScreen extends StatelessWidget {
  const BandaScreen({super.key});

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
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Agenda Banda',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgendaBandaScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Musicas Completas',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MusicasCompletasScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Piano',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PianoScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Harmond',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HarmondScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Violão',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViolaoScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Guitarra 1',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Guitarra_1Screen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Guitarra 2',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Guitarra_2Screen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'C. Baixo',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CBaixoScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Bateria',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BateriaScreen()),
              ),
            ),
            const SizedBox(height: 20),
            buildNaipeCard(
              context,
              'Strings',
              Icons.arrow_forward_ios,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StringsScreen()),
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