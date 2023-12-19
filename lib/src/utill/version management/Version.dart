// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';

import 'package:app_notificador/src/models/version.dart';
import 'package:app_notificador/src/services/providerVersion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'VersionLocal.dart';

class VersionAPI extends StatefulWidget {
  const VersionAPI({super.key});

Future<bool> validateAppVersion(BuildContext context) async {
  final deviceType = await getDeviceInfo(); // Asegúrate de definir esta función

  if (deviceType != 'Android' && deviceType != 'iOS') {
    // Si el tipo de dispositivo no es Android ni iOS, no realizas la validación.
    return true; // Retorna `true` para indicar que las versiones coinciden.
  }

  const url = 'https://notimed.sanpablo.com.pe:8443/api/version';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    String apiVersion = '';

    for (var element in jsonData['data']) {
      if ((deviceType == 'Android' && element['type'] == 'ANDROID') ||
          (deviceType == 'iOS' && element['type'] == 'IOS')) {
        apiVersion = element['version'];
        break; // Sal del bucle una vez que encuentres la versión correspondiente.
      }
    }

    // Obtener la versión local de GlobalData
    String localVersion = GlobalData().version;

    if (apiVersion != localVersion) {
      // Las versiones no coinciden, retorna `false`.
      return false;
    }

    // Las versiones coinciden, retorna `true`.
    return true;
  }

  // Si no se cumple ninguna condición, retorna `true` como valor predeterminado.
  return true;
}

  // Función para mostrar el diálogo de actualización de la aplicación

  @override
  State<VersionAPI> createState() => _VersionState();
}

class VersionProvider with ChangeNotifier {
  String _apiVersion = '';

  String get apiVersion => _apiVersion;

  void setApiVersion(String version) {
    _apiVersion = version;
    notifyListeners();
  }

  String getApiVersion() => _apiVersion;
}

class _VersionState extends State<VersionAPI> {
  late Future<List<Version>> _version;

  Future<List<Version>> _getVersion(BuildContext context) async {
    // Definir aquí tu lógica para obtener la versión
    final deviceType =
        await getDeviceInfo(); // Asegúrate de definir esta función

    if (deviceType != 'Android' && deviceType != 'iOS') {
      // Si el tipo de dispositivo no es Android ni iOS, retorna una lista vacía.
      return [];
    }

    const url = 'https://notimed.sanpablo.com.pe:8443/api/version';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));

      List<Version> versions = [];

      for (var element in jsonData['data']) {
        if ((deviceType == 'Android' && element['type'] == 'ANDROID') ||
            (deviceType == 'iOS' && element['type'] == 'IOS')) {
          String versionFromAPI = element['version'];
          versions.add(Version(
            element['type'],
            element['version'],
            element['url'],
            element['updated_at'],
          ));
          // Establecer la versión en VersionProvider
          Provider.of<VersionProvider>(context, listen: false)
              .setApiVersion(versionFromAPI);
        }
      }
      return versions;
    } else {
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }



  @override
  void initState() {
    super.initState();
    _getDeviceAndFetchVersion(context);
  }



  Future<void> _getDeviceAndFetchVersion(BuildContext context) async {
    final deviceType = await getDeviceInfo();
    if (deviceType == 'Android' || deviceType == 'iOS') {
      setState(() {
        _version = _getVersion(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FutureBuilder<List<Version>>(
          future: _version,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No se encontraron versiones.'));
            } else {
              return ListView(
                children: _buildVersionWidgets(snapshot.data!),
              );
            }
          },
        ),
      ),
    );
  }

  //llamada a la consulta
  List<Widget> _buildVersionWidgets(List<Version> data) {
    List<Widget> versionWidgets = [];

    for (var versionData in data) {
      Widget versionWidget = Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.blue, width: 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Añade esta línea
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: Colors.green.shade200,
                  ),
                  child: const Text(
                    'VERSIONES',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${versionData.type}',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${versionData.version}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${versionData.url}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${versionData.updated_at}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      );

      versionWidgets.add(versionWidget);
    }

    return versionWidgets;
  }
}
