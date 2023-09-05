import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificatonServices{

static FirebaseMessaging messaging = FirebaseMessaging.instance;
static String? tokenFB;
// ignore: prefer_final_fields, unnecessary_new
static StreamController<String> _messageStream = new StreamController.broadcast();
static Stream<String> get messagesStream => _messageStream.stream;

//apliacion abierta
static Future _backgroundHandle(RemoteMessage message) async{
  'onBackground Handle ${message.messageId}';
//_messageStream.add(message.notification?.title?? 'no title');
}

//aplicacion en pause
static Future _onMessageHandle(RemoteMessage message) async{
  'onMessageHandle Handle ${message.messageId}';
  //_messageStream.add(message.notification?.title?? 'no title');
} 
 
//aplicacion cerrada
static Future _onMessageOpenApp(RemoteMessage message) async{
  'onMessageOpenApp Handle ${message.messageId}';
  //_messageStream.add(message.notification?.title?? 'no title');
} 


static Future initializeApp() async{

//push notification

await Firebase.initializeApp();
tokenFB = await FirebaseMessaging.instance.getToken();
// ignore: avoid_print
print(tokenFB);

//handle

FirebaseMessaging.onBackgroundMessage(_backgroundHandle);

FirebaseMessaging.onMessage.listen(_onMessageHandle);

FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

}

static closeStream(){
  _messageStream.close();
}

}
