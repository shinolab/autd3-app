import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Geometry {
  Geometry(
      {required this.x,
      required this.y,
      required this.z,
      required this.rz1,
      required this.ry,
      required this.rz2});

  double x = 0;
  double y = 0;
  double z = 0;
  double rz1 = 0;
  double ry = 0;
  double rz2 = 0;

  Geometry.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'],
        z = json['z'],
        rz1 = json['rz1'],
        ry = json['ry'],
        rz2 = json['rz2'];

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'z': z,
        'rz1': rz1,
        'ry': ry,
        'rz2': rz2,
      };
}

class Settings {
  Settings();

  String ip = '';
  int port = 8080;
  List<Geometry> geometry = [];

  fromJson(Map<String, dynamic> json) {
    ip = json['ip'];
    port = json['port'];
    geometry = List<Geometry>.from(
        json['geometries'].map((geometry) => Geometry.fromJson(geometry)));
  }

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'port': port,
        'geometries': geometry,
      };

  Future load(String jsonPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, jsonPath));
    if (!(await file.exists())) {
      _setDefault();
      return;
    }

    try {
      final jsonStr = await file.readAsString();
      Map<String, dynamic> settingMap = json.decode(jsonStr);
      fromJson(settingMap);
    } catch (e) {
      _setDefault();
      return;
    }
  }

  Future save(String jsonPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final jsonStr = json.encode(toJson());
    await File(p.join(directory.path, jsonPath)).writeAsString(jsonStr);
  }

  _setDefault() {
    ip = '';
    port = 8080;
    geometry = [];
  }
}
