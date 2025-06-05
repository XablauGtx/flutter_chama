// lib/widgets/my_drawer.dart

import 'package:flutter/material.dart';
// Imports para todas as telas que estarão no menu
import 'package:chama_app/home_screen.dart';
import 'package:chama_app/screens/recados_screen.dart';
import 'package:chama_app/screens/agenda_screen.dart';
import 'package:chama_app/screens/kits_de_voz_screen.dart';
import 'package:chama_app/screens/letras_screen.dart';
import 'package:chama_app/screens/banda_screen.dart';
import 'package:chama_app/screens/partituras_screen.dart';
import 'package:chama_app/screens/cifras_screen.dart';
import 'package:chama_app/screens/oracao_screen.dart';
import 'package:chama_app/screens/novo_coralista_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // Função auxiliar para criar os itens do menu
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(text, style: const TextStyle(color: Colors.white, fontFamily: 'Nexa')),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF192F3C),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              image: const DecorationImage(
                image: AssetImage("assets/images/chama_coral.png"),
                fit: BoxFit.contain,
                opacity: 0.5,
              ),
            ),
            child: const Text(
              'Chama Coral',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Nexa',
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            text: 'Início',
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              // Leva para a tela inicial. popUntil remove todas as telas da pilha.
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          _buildDrawerItem(
            icon: Icons.campaign,
            text: 'Recados',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RecadosScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            text: 'Agenda',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.queue_music,
            text: 'Kits de Voz',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const KitsDeVozScreen()));
            },
          ),
           _buildDrawerItem(
            icon: Icons.lyrics_outlined,
            text: 'Letras',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LetrasScreen()));
            },
          ),
          const Divider(color: Colors.white30),
           _buildDrawerItem(
            icon: Icons.music_video,
            text: 'Banda',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BandaScreen()));
            },
          ),
           _buildDrawerItem(
            icon: Icons.auto_stories,
            text: 'Partituras',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PartiturasScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.queue_music_outlined,
            text: 'Cifras',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CifrasScreen()));
            },
          ),
           const Divider(color: Colors.white30),
          _buildDrawerItem(
            icon: Icons.church,
            text: 'Oração',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OracaoScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_add,
            text: 'Novo Coralista',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NovoCoralistaScreen()));
            },
          ),
        ],
      ),
    );
  }
}