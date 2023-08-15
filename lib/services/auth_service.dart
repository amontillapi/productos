import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:productos/auth/keys.dart';

class AuthService extends ChangeNotifier {
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken =
      SecretLoader(secretPath: 'firebase_token').secretPath;

  final storage = const FlutterSecureStorage();

  Future<String?> createUser(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final url =
        Uri.https(_baseUrl, '/v1/accounts:signUp', {'key': _firebaseToken});

    final Response response = await http.post(url, body: json.encode(authData));

    final Map<String, dynamic> decodedResponse = json.decode(response.body);

    if (decodedResponse.containsKey('idToken')) {
      await storage.write(key: 'token', value: decodedResponse['idToken']);
      return null;
    } else {
      return (decodedResponse['error'] as Map<String, dynamic>)['message'];
    }
  }

  Future<String?> login(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final url = Uri.https(
      _baseUrl,
      '/v1/accounts:signInWithPassword',
      {'key': _firebaseToken},
    );

    final Response response = await http.post(url, body: json.encode(authData));

    final Map<String, dynamic> decodedResponse = json.decode(response.body);

    if (decodedResponse.containsKey('idToken')) {
      await storage.write(key: 'token', value: decodedResponse['idToken']);

      return null;
    } else {
      return (decodedResponse['error'] as Map<String, dynamic>)['message'];
    }
  }

  Future logOut() async {
    await storage.delete(key: 'token');
    return;
  }

  Future<String?> readToken() async {
    return await storage.read(key: 'token') ?? '';
  }
}
