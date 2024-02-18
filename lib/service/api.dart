import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  token() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return '?token=$token';
  }

  login(data) async {
    var fullUrl = 'http://127.0.0.1:8080/api/login' + await token();

    Response response = await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    return response;
  }

  Future<List<Map<String, dynamic>>> getSchedule() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? token = localStorage.getString('token');

    if (token == null) {
      throw Exception('Erreur d\'authentification, token manquant');
    }
    try {
      final url = Uri.parse('http://127.0.0.1:8080/api/patients');
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Map<String, dynamic>> rendezVousDetails = [];

        for (final item in data) {
          final patientId = item['patient']['id'];
          final patientPrenom = item['patient']['user']['firstname'];
          final patientNom = item['patient']['user']['lastname'];
          final doctorId = item['doctor']['id'];
          final dateDebut = item['dateTimeBegin'];
          final dateFin = item['dateTimeEnd'];

          rendezVousDetails.add({
            'id': item['id'],
            'patient': {
              'prenom': patientPrenom,
              'nom': patientNom,
              'id': patientId
            },
            'doctor': {'id': doctorId},
            'dateDebut': dateDebut,
            'dateFin': dateFin,
          });
        }
        return rendezVousDetails;
      } else {
        // Handle failed API request (e.g., log error, show user-friendly message)
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (error) {
      // Handle unexpected errors (e.g., network issues)
      throw Exception('Error fetching schedule: $error');
    }
  }
}
