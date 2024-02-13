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

  Future<List<Map<String, dynamic>>> getDrugsList() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? token = localStorage.getString('token');

    if (token == null) {
      // Handle missing token gracefully, e.g., redirect to login
      throw Exception('Authentication error: Token missing');
    }

    try {
      final url = Uri.parse('http://127.0.0.1:8080/api/drugs');
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Map<String, dynamic>> listDrugs = [];

        for (final item in data) {
          final drugId = item['id'];
          final drugName = item['name'];

          listDrugs.add({
            'id': drugId,
            'name': drugName,
          });
        }
        return listDrugs;
      } else {
        // Handle failed API request (e.g., log error, show user-friendly message)
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (error) {
      // Handle unexpected errors (e.g., network issues)
      throw Exception('Error fetching schedule: $error');
    }
  }

  Future<void> setPrescription(Map<String, dynamic> jsonData) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? token = localStorage.getString('token');

    if (token == null) {
      // Token manquant
      throw Exception('Erreur d\'authentification, token manquant');
    }

    try {
      final url = Uri.parse('http://127.0.0.1:8080/api/prescription');
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode(jsonData);
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        // Handle successful response, e.g., show success message
        print('Prescription crée avec succès');
      } else {
        // Handle failed API request (e.g., log error, show user-friendly message)
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (error) {
      // Handle unexpected errors (e.g., network issues)
      throw Exception('Error setting prescription: $error');
    }
  }
}
