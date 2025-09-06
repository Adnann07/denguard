import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:uuid/uuid.dart';

class DialogflowService {
  static final DialogflowService _instance = DialogflowService._internal();
  factory DialogflowService() => _instance;
  DialogflowService._internal();

  static const _scopes = ['https://www.googleapis.com/auth/cloud-platform'];

  String _projectId = 'denguard-works'; // Replace with your actual project ID
  String _sessionId = const Uuid().v4();
  AutoRefreshingAuthClient? _client;

  Future<void> _initClient() async {
    if (_client != null) return;

    final serviceAccountJson =
    await rootBundle.loadString('assets/denguard-works-93f4c84b92ef.json');
    final serviceAccount = ServiceAccountCredentials.fromJson(serviceAccountJson);

    _client = await clientViaServiceAccount(serviceAccount, _scopes);
  }

  Future<String> detectIntent(String query) async {
    await _initClient();

    final url = Uri.parse(
      'https://dialogflow.googleapis.com/v2/projects/$_projectId/agent/sessions/$_sessionId:detectIntent',
    );

    final response = await _client!.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        "queryInput": {
          "text": {
            "text": query,
            "languageCode": "bn" // Use "en" for English, "bn" for Bangla
          }
        }
      }),
    );

    final data = jsonDecode(response.body);

    try {
      return data['queryResult']['fulfillmentText'] ?? 'No response';
    } catch (_) {
      return 'Could not understand that.';
    }
  }
}
