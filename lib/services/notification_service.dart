import 'package:chama_app/navigation/navigator_key.dart';
import 'package:chama_app/screens/recado_detail_screen.dart';
import 'package:chama_app/screens/recados_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  static const String allUsersTopic = "avisos_gerais"; 

  Future<void> initialize() async {
    debugPrint("--- A iniciar o Serviço de Notificações ---");
    
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("[SUCESSO] Permissão de notificação concedida.");
      
      await _firebaseMessaging.subscribeToTopic(allUsersTopic);
      debugPrint("[SUCESSO] App inscrito no tópico: $allUsersTopic");

    } else {
      debugPrint("[FALHA] Permissão de notificação negada pelo utilizador.");
    }
    
    // Ouve por mensagens enquanto o aplicativo está aberto.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Recebida uma notificação com o app aberto!');
      debugPrint('Título: ${message.notification?.title}, Corpo: ${message.notification?.body}');
    });

    // Ouve por cliques em notificações quando o app está em segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Verifica se o app foi aberto a partir de uma notificação (quando estava fechado)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    debugPrint("--- Serviço de Notificações Terminado ---");
  }

  /// Lida com a navegação quando uma notificação é clicada.
  void _handleMessage(RemoteMessage message) async {
    if (message.data['screen'] == 'recado_detail') {
      final recadoId = message.data['recadoId'];
      if (recadoId != null) {
        try {
          final doc = await FirebaseFirestore.instance.collection('recados').doc(recadoId).get();
          if (doc.exists) {
            final data = doc.data()!;
            final timestamp = data['timestamp'] as Timestamp?;
            
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => RecadoDetailScreen(
                  title: data['titulo'] ?? '',
                  content: data['conteudo'] ?? '',
                  imageUrl: data['imagemUrl'] ?? '',
                  date: timestamp?.toDate() ?? DateTime.now(),
                ),
              ),
            );
          }
        } catch (e) {
          print("Erro ao buscar documento do recado: $e");
        }
      }
    } else if (message.data['screen'] == 'recados') {
        navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const RecadosScreen()),
        );
    }
  }
}
