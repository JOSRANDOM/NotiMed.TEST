// ignore_for_file: file_names

import 'dart:convert';

import 'package:app_notificador/src/models/version.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/providerVersion.dart';
import 'VersionLocal.dart';

void main() => runApp(const VersionAPI());

class VersionAPI extends StatefulWidget {
  const VersionAPI({super.key});

  @override
  State<VersionAPI> createState() => _VersionState();
}

class _VersionState extends State<VersionAPI> {
  late Future<List<Version>> _version;

Future<List<Version>> _getVersion(BuildContext context) async {
  final deviceType = await getDeviceInfo();

  if (deviceType != 'Android' && deviceType != 'iOS') {
    // Si el tipo de dispositivo no es Android ni iOS, retorna una lista vacía.
    return [];
  }

  const url = 'https://notimed.sanpablo.com.pe:8443/api/version';

  final response = await http.get(
    Uri.parse(url),
  );

  List<Version> _version = [];

  if (response.statusCode == 200) {
    String body = utf8.decode(response.bodyBytes);
    final jsonData = jsonDecode(body);

    for (var element in jsonData['data']) {
      if ((deviceType == 'Android' && element['type'] == 'ANDROID') ||
          (deviceType == 'iOS' && element['type'] == 'IOS')) {
        String versionFromAPI = element['version'];
        if (versionFromAPI == GlobalData().version.toString()) {
          // Verifica si la versión de la API es igual a la versión en GlobalData.
          _version.add(Version(
            element['type'],
            element['version'],
            element['url'],
            element['updated_at'],
          ));
        } else {
          // Si las versiones no coinciden, puedes mostrar un mensaje o realizar otra acción.
          print('Versiones no coinciden: Versión API: $versionFromAPI, Versión local: ${GlobalData().version}');
        }
      }
    }
    return _version;
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No se encontraron versiones.'),
            );
          } else {
            return ListView(
              children: _versiones(snapshot.data ?? []), // Mostrar la lista de versiones
            );
          }
        },
      ),
    ),
  );
}




//llamada a la consulta
  List<Widget> _versiones(List<Version> data) {
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
             const SizedBox(height: 10,)
            ],
          ),
        ),
      );

      versionWidgets.add(versionWidget);
    }

    return versionWidgets;
  }
}
