import 'package:flutter/material.dart';
import 'package:nttdatapay_flutter/nttdatapay_flutter.dart';

class NttDataPay extends StatefulWidget {
  double? grandTotal;
  NttDataPay({super.key, this.grandTotal});

  @override
  State<NttDataPay> createState() => _NttDataPayState();
}

class _NttDataPayState extends State<NttDataPay> {
  bool loading = false;
  late String txnId;

  /// Merchant configuration (for demo/testing only; never hardcode production secrets)
  final nttdatapayConfig = NttdatapayConfig(
    merchId: "317159",
    txnPassword: "Test@123",
    reqEncKey: "A4476C2062FFA58980DC8F79EB6A799E",
    reqSalt: "A4476C2062FFA58980DC8F79EB6A799E",
    resDecKey: "75AEF0FA1B94B3C10D4F5B268F757F11",
    resSalt: "75AEF0FA1B94B3C10D4F5B268F757F11",
    reqHashKey: "KEY123657234",
    resHashKey: "KEYRESP123657234",
    environment: NttdatapayEnvironment
        .uat, // Switch to production for live transactionsSSS
  );

  /// Generate payment token and initiate checkout flow
  Future<void> _payNow(BuildContext context) async {
    /// User information (for payment request)
    const String email = "kmlesh90@gmail.com";
    const String mobile = "8299166374";
    final String amount = widget.grandTotal != null
        ? widget.grandTotal.toString()
        : "1.00";

    final BuildContext ctx = context;

    setState(() {
      loading = true;
      txnId = "INV${DateTime.now().millisecondsSinceEpoch}";
    });

    try {
      /// Generate transaction token from NTTDATAPAY
      // final ndpsTokenId = await NdpsAuthService.generateToken(
      //   config: nttdatapayConfig,
      //   txnId: txnId,
      //   amount: amount,
      //   email: email,
      //   mobile: mobile,
      //   prodId: "NSE", // multi in case of split payments (multi-product)
      // prodDetails: const [                                    // Add Multi-Product (Split Payment) Support
      //   ProdDetail(prodName: "XXX", prodAmount: "1.00"),
      //   ProdDetail(prodName: "XXXX", prodAmount: "1.00"),
      // ],
      // custAccNo: "213232323",
      // clientCode: "testValueForClientCode",
      // txnCurrency: "INR",
      // udf1: "udf1", // optional
      // udf2: "udf2", // optional
      // udf3: "udf3", // optional
      // udf4: "udf4", // optional
      // udf5: "udf5", // optional
      final ndpsTokenId = await NdpsAuthService.generateToken(
        config: nttdatapayConfig,
        txnId: txnId, // unique transaction Id
        amount: "1.00",
        email: "test.user@xyz.in",
        mobile: "8888888800",
        prodId: "NSE",
        txnCurrency: "INR",
      );

      if (!ctx.mounted) return;

      setState(() => loading = false);

      /// Open checkout WebView and wait for the final payment result
      final NdpsPaymentResult? result = await Navigator.push<NdpsPaymentResult>(
        ctx,
        MaterialPageRoute(
          builder: (_) => NdpsPaymentWebView(
            ndpsTokenId: ndpsTokenId,
            merchId: nttdatapayConfig.merchId,
            returnUrl: nttdatapayConfig.returnUrl,
            config: nttdatapayConfig,
            email: email,
            mobile: mobile,
            showAppBar: true,
            appBarTitle: "Complete Payment",
          ),
        ),
      );

      if (!ctx.mounted) return;

      /// HANDLE RESULT
      if (result == null) {
        _showSnack(ctx, "Payment window closed by user", Colors.orange);
        return;
      }

      // Transaction status
      final String status = result.status;
      debugPrint("Transaction status => $status"); // OTS0000 is success

      // Transaction description
      final String description = result.description.toString();
      debugPrint("Transaction description => $description");

      // Full transaction response (raw JSON map)
      final Map<String, dynamic> transactionResponse = result.rawResponse;
      debugPrint("Transaction response => $transactionResponse");

      switch (status) {
        // success
        case "OTS0000":
          _showSnack(ctx, "Payment Successful", Colors.green);
          break;

        // pending payment and NEFT/RTGS payment initial status
        case "OTS0551":
        case "PENDING":
          _showSnack(
            ctx,
            result.description.isNotEmpty
                ? result.description
                : "Payment Pending",
            Colors.orange,
          );
          break;

        // failed
        case "OTS0600":
          _showSnack(ctx, "Payment Failed", Colors.red);
          break;

        case "CANCELLED":
          _showSnack(ctx, "Payment cancelled by user", Colors.orange);
          break;

        case "TIMEOUT":
          _showSnack(
            ctx,
            "Session timed out. Please try again.",
            Colors.orange,
          );
          break;

        default:
          _showSnack(ctx, "Payment Failed (Status: $status)", Colors.red);
      }
    } catch (e) {
      if (!ctx.mounted) return;
      setState(() => loading = false);
      _showSnack(ctx, "Payment initiation failed: $e", Colors.red);
    }
  }

  /// Snack helper (context-safe)
  void _showSnack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NTTDATAPAY Demo"), centerTitle: true),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _payNow(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: const Text("Pay Now", style: TextStyle(fontSize: 16)),
              ),
      ),
    );
  }
}
