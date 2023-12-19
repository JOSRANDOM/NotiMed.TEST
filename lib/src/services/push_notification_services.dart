// ignore_for_file: unnecessary_new, prefer_final_fields, avoid_print

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:audioplayers/audioplayers.dart';

class PushNotificatonServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? tokenFB;
  static StreamController<String> _messageStream = new StreamController.broadcast();
  static Stream<String> get messagesStream => _messageStream.stream;
  static AudioPlayer _audioPlayer = AudioPlayer();

  static Future _backgroundHandle(RemoteMessage message) async {
    print('onBackground Handle ${message.messageId}');
    await _audioPlayer.play('lib/src/images/vozNotimed.mp3' as Source);
    // Puedes agregar aquí lógica específica de manejo en segundo plano si es necesario
  }

  static Future _onMessageHandle(RemoteMessage message) async {
    print('onMessageHandle Handle ${message.messageId}');
    // Reproduce el tono personalizado cuando llega una notificación
    await _audioPlayer.play('lib/src/images/vozNotimed.mp3' as Source);
    // Aquí puedes agregar más lógica para manejar la notificación si es necesario
    //_messageStream.add(message.notification?.title ?? 'no title');
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    print('onMessageOpenApp Handle ${message.messageId}');
    await _audioPlayer.play('lib/src/images/vozNotimed.mp3' as Source);
    // Puedes agregar aquí lógica específica cuando se abre la aplicación desde una notificación
    //_messageStream.add(message.notification?.title ?? 'no title');
  }

  static Future initializeApp() async {
    // Inicialización de Firebase
    await Firebase.initializeApp();
    tokenFB = await FirebaseMessaging.instance.getToken();
    print(tokenFB);

    // Configuración de Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_backgroundHandle);
    FirebaseMessaging.onMessage.listen(_onMessageHandle);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  }

  static closeStream() {
    _messageStream.close();
  }
}
