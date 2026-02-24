import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NttWebViewPayment extends StatefulWidget {
   NttWebViewPayment({super.key});

  @override
  State<NttWebViewPayment> createState() => _NttWebViewPaymentState();
}

class _NttWebViewPaymentState extends State<NttWebViewPayment> {
  late final WebViewController _controller;

  // Generate this URL from your backend (POST params to NTT endpoint)
  final String paymentUrl = "https://paynetzuat.atomtech.in/mobilesdk/param";  // UAT example

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains("your-return-url-domain")) {
              // Parse success/failure from URL or postMessage
              Navigator.pop(context, "success"); // Or handle accordingly
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));  // Or load HTML form with POST
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NTT Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}