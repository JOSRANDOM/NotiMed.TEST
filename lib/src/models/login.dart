// ignore_for_file: non_constant_identifier_names

class LoginData {
  String? username;
  String name;
  String cmp;
  String? password;
  String? tokenFB;
  String? dni;
  String? email;
  String? phone;
  String? tokenBD;
  int type_doctor;
  List<Clinic>? clinics; // Cambio en la declaración de clinics

  LoginData(
    this.username,
    this.name,
    this.cmp,
    this.password,
    this.tokenFB,
    this.dni,
    this.email,
    this.phone,
    this.tokenBD,
    this.type_doctor,
    this.clinics,
  );
}

class Clinic {
  int id;
  String name;
  String nameShort;
  String color;

  Clinic(this.id, this.name, this.nameShort, this.color);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_short': nameShort,
      'color': color,
    };
  }
}

