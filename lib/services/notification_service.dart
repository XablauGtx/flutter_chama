import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // O nome do "canal" para onde enviaremos as notificações em massa.
  static const String allUsersTopic = "avisos_gerais"; 

  Future<void> initialize() async {
    debugPrint("--- A iniciar o Serviço de Notificações ---");
    
    // 1. Pedir permissão ao utilizador para receber notificações.
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // 2. Verificar se o utilizador concedeu a permissão.
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("[SUCESSO] Permissão de notificação concedida.");
      
      // 3. Inscreve o dispositivo neste tópico.
      // A partir de agora, ele receberá todas as mensagens enviadas para 'avisos_gerais'.
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

    debugPrint("--- Serviço de Notificações Terminado ---");
  }
}