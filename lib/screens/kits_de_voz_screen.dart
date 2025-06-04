// lib/screens/kits_de_voz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chama_app/screens/kitvoz/quatro_vozes.dart';
import 'package:chama_app/screens/kitvoz/quatro_vozes_acapella.dart';
import 'package:chama_app/screens/kitvoz/sopranos.dart';
import 'package:chama_app/screens/kitvoz/contralto.dart';
import 'package:chama_app/screens/kitvoz/tenores.dart';
import 'package:chama_app/screens/kitvoz/baixos.dart';



class KitsDeVozScreen extends StatelessWidget {
  const KitsDeVozScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chama Coral', // Título da AppBar conforme sua imagem
          style: TextStyle(
            fontFamily: 'Nexa',
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF192F3C), // Cor escura para a AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Retorna à tela anterior
          },
        ),
        // Ícone de menu hambúrguer, se desejar (não funcional aqui)
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white), // Ícone de menu hambúrguer
            onPressed: () {
              // Ação para o menu hambúrguer (ex: abrir Drawer)
              Scaffold.of(context).openDrawer(); // Descomente se tiver um Drawer
            },
          ),
          // Se tiver um ícone de configurações/informação no canto superior direito como nas suas imagens
          // IconButton(
          //   icon: const Icon(Icons.settings, color: Colors.white), // Exemplo de ícone de configurações
          //   onPressed: () {
          //     // Ação para configurações
          //   },
          // ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'), // Seu wallpaper de fundo
            fit: BoxFit.cover,
          ),
        ),
        child: ListView( // Usando ListView para permitir rolagem se houver muitos itens
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          children: [
            // Cartão para "4 vozes" - se houver uma tela específica para isso
            // Se '4 vozes' ou '4 vozes acapella' forem coleções diferentes no Firestore,
            // você precisaria de telas separadas para elas também, seguindo o padrão.
            // Por enquanto, vamos assumir que os botões levam para as telas de naipe.
            buildNaipeCard(context, '4 vozes', Icons.camera_alt, () => null), // Não navega por enquanto
            const SizedBox(height: 10),
            buildNaipeCard(context, '4 vozes acapella', Icons.camera_alt, () => null), // Não navega por enquanto
            const SizedBox(height: 10),

            buildNaipeCard(
              context,
              'Sopranos',
              Icons.camera_alt,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SopranoScreen()),
              ),
            ),
            const SizedBox(height: 10),
            buildNaipeCard(
              context,
              'Contraltos',
              Icons.camera_alt,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContraltoScreen()),
              ),
            ),
            const SizedBox(height: 10),
            buildNaipeCard(
              context,
              'Tenores',
              Icons.camera_alt,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TenoresScreen()),
              ),
            ),
            const SizedBox(height: 10),
            buildNaipeCard(
              context,
              'Baixos',
              Icons.camera_alt,
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

  // Widget para construir cada cartão de naipe
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
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          child: Row(
            children: [
              // Ícone da chama (se for um SVG, use SvgPicture.asset)
              // Se for um ícone normal do Material, use Icon
              // Exemplo com ícone de chama se for um SVG:
              // SvgPicture.asset(
              //   'assets/images/chama_icon.svg', // Substitua pelo caminho do seu ícone de chama
              //   width: 40,
              //   height: 40,
              //   colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn), // Cor da chama
              // ),
              // Ou um placeholder simples por enquanto:
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