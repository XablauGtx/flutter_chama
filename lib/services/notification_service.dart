import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const String allUsersTopic = "avisos_gerais"; // Nome do nosso tópico

  Future<void> initialize() async {
    // 1. Pedir permissão ao utilizador
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permissão de notificação concedida pelo utilizador.');
      
      // 2. Inscreve o dispositivo no tópico geral
      await _firebaseMessaging.subscribeToTopic(allUsersTopic);
      debugPrint('Inscrito no tópico: $allUsersTopic');

    } else {
      debugPrint('Permissão de notificação negada pelo utilizador.');
    }
  }
}