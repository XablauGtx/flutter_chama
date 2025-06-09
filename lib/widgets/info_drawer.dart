import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoDrawer extends StatelessWidget {
  const InfoDrawer({super.key});

  // Função para abrir uma URL no navegador externo
  Future<void> _launchURL(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o link: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF192F3C),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 200, // Altura do cabeçalho
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black38,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/chama_coral4.svg', // Seu novo logo
                    height: 80,
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Redes Sociais',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Nexa',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Itens de menu com os links e ícones SVG
          _buildSocialItem(
            context,
            assetPath: 'assets/images/instagram.svg',
            text: 'Instagram',
            url: 'https://www.instagram.com/chamacoral',
          ),
          _buildSocialItem(
            context,
            assetPath: 'assets/images/youtube.svg',
            text: 'YouTube',
            url: 'https://www.youtube.com/channel/UCa1sct4x9Baek5lXr2ttEIQ',
          ),
          _buildSocialItem(
            context,
            assetPath: 'assets/images/youtube_music.svg',
            text: 'YouTube Music',
            url: 'https://music.youtube.com/channel/UCodEbhZJaFVIwR-B-xKsK7w',
          ),
          _buildSocialItem(
            context,
            assetPath: 'assets/images/spotify.svg',
            text: 'Spotify',
            url: 'https://open.spotify.com/intl-pt/artist/0TDC1ivOZb4LiNYWYirJ2B',
          ),
          _buildSocialItem(
            context,
            assetPath: 'assets/images/deezer.svg',
            text: 'Deezer',
            url: 'https://www.deezer.com/br/artist/7866196',
          ),
          _buildSocialItem(
            context,
            assetPath: 'assets/images/apple_music.svg',
            text: 'Apple Music',
            url: 'https://music.apple.com/br/artist/ministério-chama-coral/989049377',
          ),
          _buildSocialItem(
            context,
            assetPath: 'assets/images/facebook.svg',
            text: 'Facebook',
            url: 'https://www.facebook.com/chamacoral/?locale=pt_BR',
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar cada item do menu
  Widget _buildSocialItem(BuildContext context, {required String assetPath, required String text, required String url}) {
    return ListTile(
      leading: SvgPicture.asset(
        assetPath,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFFF44336), BlendMode.srcIn), // Colore o SVG em vermelho
      ),
      title: Text(text, style: const TextStyle(color: Colors.white, fontFamily: 'Nexa')),
      onTap: () => _launchURL(url, context),
    );
  }
}
