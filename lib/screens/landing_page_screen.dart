import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LandingPageScreen extends StatefulWidget {
  final String htmlContent;
  final String? filePath; // optional

  const LandingPageScreen({super.key, required this.htmlContent, this.filePath});

  @override
  State<LandingPageScreen> createState() => _LandingPageScreenState();
}

class _LandingPageScreenState extends State<LandingPageScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('OrderChannel', onMessageReceived: _onOrderMessage)
      ..loadRequest(Uri.dataFromString(widget.htmlContent, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')));
  }

  void _onOrderMessage(JavaScriptMessage message) {
    // Expect JSON with type and payload
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is Map && decoded['type'] == 'ORDER_PLACED') {
        final payload = decoded['payload'];
        final orderId = payload['orderId'] ?? 'unknown';

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width:8), Text('Order placed')]),
            content: Text('Order $orderId has been placed (simulated).'),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          ),
        );
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Landing Page Preview')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
