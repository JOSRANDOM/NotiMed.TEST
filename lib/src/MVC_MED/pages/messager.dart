import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MessagerSP());

class MessagerSP extends StatelessWidget {
  const MessagerSP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: NotificationPermissionPage(),
    );
  }
}

class NotificationPermissionPage extends StatefulWidget {
  @override
  _NotificationPermissionPageState createState() => _NotificationPermissionPageState();
}

class _NotificationPermissionPageState extends State<NotificationPermissionPage> {
  PermissionStatus? _notificationStatus;

  @override 
  void initState() {
    super.initState();
    _checkNotificationPermissionStatus();
  }

  Future<void> _checkNotificationPermissionStatus() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationStatus = status;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    String permissionText = 'Permisos sin conceder';

    if (_notificationStatus == PermissionStatus.granted) {
      permissionText = 'Permisos concedidos';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MENSAJERIA INTERNA'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Estado de los permisos de notificación: ${_notificationStatus.toString()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestNotificationPermission,
              child: const Text('Solicitar Permiso de Notificación'),
            ),
            const SizedBox(height: 20),
            Text(
              permissionText,
              style: TextStyle(fontSize: 16, color: _notificationStatus == PermissionStatus.granted ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
