// checkout/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nscd_app_for_booking/NTT%20Payment%20Services/ntt_data_pay.dart';
import 'package:nscd_app_for_booking/NTT%20Payment%20Services/ntt_webview.dart';

import 'package:nscd_app_for_booking/ticket.dart'; // assuming CartItem lives here

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId = 'addr1'; // default for demo

  // Dummy addresses — replace with real data source later
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 'addr1',
      'name': 'Ubaid Khan',
      'phone': '8111558287',
      'address': 'Aashiyana, Sector K1, Lucknow, Uttar Pradesh - 226024',
      'isDefault': true,
    },
    {
      'id': 'addr2',
      'name': 'IT Chauraha',
      'phone': '9878567878',
      'address':
          'It Chauraha Lucknow Uttar Pradesh, Lucknow, Uttar Pradesh - 222022',
      'isDefault': false,
    },
  ];

  double get grandTotal =>
      widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      print(args);
    } else {
      print('no');
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Address Section Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Delivery Address',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ..._addresses.map((addr) {
              final isSelected = _selectedAddressId == addr['id'];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedAddressId = addr['id']);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue.shade600
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<String>(
                        value: addr['id'],
                        groupValue: _selectedAddressId,
                        onChanged: (v) =>
                            setState(() => _selectedAddressId = v),
                        activeColor: Colors.blue,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  addr['name'],
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '(${addr['phone']})',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              addr['address'],
                              style: GoogleFonts.roboto(
                                height: 1.4,
                                color: Colors.grey[800],
                              ),
                            ),
                            if (addr['isDefault'] == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'DEFAULT',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: Colors.green[900],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add new address coming soon...'),
                  ),
                );
                // new address Page
              },
              icon: const Icon(Icons.add, color: Colors.blue, size: 20),
              label: Text(
                'Add New Address',
                style: GoogleFonts.roboto(
                  color: Colors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Order Summary Section ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Order Summary',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Full replacement widget
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  // Modern header (less "table", more branded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade800],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          color: Colors.white70,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Your Tickets",
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${widget.cartItems.length} items",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Items – each as ticket card
                  ...widget.cartItems.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    final isNormal = item.subCategory == "Normal Ticket";

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Material(
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            "$idx",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: GoogleFonts.roboto(
                                                  fontSize: 16.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (item.subtitle != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 3,
                                                      ),
                                                  child: Text(
                                                    item.subtitle!,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "₹${item.totalPrice.toStringAsFixed(2)}",
                                          style: GoogleFonts.roboto(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Metadata line
                                    // Row(
                                    //   children: [
                                    //     _infoChip(
                                    //       Icons.group,
                                    //       "Qty: ${item.quantity}",
                                    //     ),
                                    //     const SizedBox(width: 12),
                                    //     _infoChip(
                                    //       Icons.style,
                                    //       item.subCategory,
                                    //       bgColor: isNormal
                                    //           ? Colors.grey[200]
                                    //           : Colors.blue[100],
                                    //       textColor: isNormal
                                    //           ? Colors.black87
                                    //           : Colors.blue[900],
                                    //     ),
                                    //     if (item.subCategoryDetail != null) ...[
                                    //       const SizedBox(width: 8),
                                    //       _infoChip(
                                    //         Icons.info_outline,
                                    //         item.subCategoryDetail!,
                                    //         bgColor: Colors.purple[50],
                                    //         textColor: Colors.purple[800],
                                    //       ),
                                    //     ],
                                    //   ],
                                    // ),
                                    if (item.timeSlot.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.timeSlot,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Optional delete
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Grand total – prominent & fixed-looking
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                        Text(
                          "₹${grandTotal.toStringAsFixed(2)}",
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Helper widget
            const SizedBox(height: 40),

            // ── Place Order Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _selectedAddressId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NttDataPay(grandTotal: grandTotal),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Placing order securely..."),
                          ),
                        );
                        // TODO: proceed to payment gateway / order confirmation
                      },
                icon: const Icon(Icons.lock, size: 20),
                label: Text(
                  "Place Order Securely",
                  style: GoogleFonts.roboto(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) => Text(
    text,
    style: GoogleFonts.roboto(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    ),
  );

  Widget _infoChip(
    IconData icon,
    String label, {
    Color? bgColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor ?? Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
