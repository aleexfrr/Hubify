import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hubify/constants/status_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SteamLoginWebView extends StatefulWidget {
  final Function(Map<String, dynamic>) onLoginSuccess;

  const SteamLoginWebView({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  _SteamLoginWebViewState createState() => _SteamLoginWebViewState();
}

class _SteamLoginWebViewState extends State<SteamLoginWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            if (url.contains("http://${StatusData.ipAddress}:3000/steam/login/return")) {
              try {
                final jsonString = await _controller.runJavaScriptReturningResult("document.body.innerText;");
                
                // jsonString puede venir con comillas extras, limpiamos:
                String cleaned = jsonString.toString();
                if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
                  cleaned = cleaned.substring(1, cleaned.length - 1);
                  cleaned = cleaned.replaceAll(r'\"', '"'); // desescapamos comillas
                }

                final Map<String, dynamic> data = jsonDecode(cleaned);

                widget.onLoginSuccess(data);

                //if (mounted) Navigator.pop(context);
              } catch (e) {
                print("Error al obtener JSON desde WebView: $e");
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse("http://${StatusData.ipAddress}:3000/steam/login"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar sesión con Steam")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
