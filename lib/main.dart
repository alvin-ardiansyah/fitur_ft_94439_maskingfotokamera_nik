import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.microphone.request();

  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: WebViewApp(),
  ));
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  InAppWebViewController? controller;

  final host = 'https://98ad-202-138-247-143.ngrok-free.app/devalvin';

  @override
  void initState() {
    super.initState();
    _loadWebViewWithHeaders();
  }

  Future<void> _loadWebViewWithHeaders() async {
    final requestHeaders = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': '4646'
    };
    final response = await http.get(
        Uri.parse(
            '$host/api/mobile/get-token?rsid=134&rskey=5SG5YLR4MD437DNJPQTECDX9MUXL45'),
        headers: requestHeaders);

    if (response.statusCode != 200) {
      print('Error: gagal mendapatkan token');
      print(response.body);
      return;
    }

    final jsonResponse = jsonDecode(response.body);
    final token = jsonResponse['data']['token'];

    Map<String, String> headers = {
      "Authorization": 'Bearer $token',
      'ngrok-skip-browser-warning': '4646'
    };

    // Check if controller is initialized before loading the URL
    if (mounted) {
      controller?.loadUrl(
          urlRequest:
              URLRequest(url: Uri.parse('$host/mobile/ocr'), headers: headers));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            mediaPlaybackRequiresUserGesture: false,
            javaScriptEnabled: true,
          ),
        ),
        onWebViewCreated: (controller) {
          this.controller = controller; // Initialize the controller
        },
        androidOnPermissionRequest: (controller, origin, resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED);
        },
        
      ),
    );
  }
}
