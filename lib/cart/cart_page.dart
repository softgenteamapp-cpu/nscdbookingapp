import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nscd_app_for_booking/checkout/checkout_page.dart';
import 'package:nscd_app_for_booking/ticket.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get grandTotal =>
      widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
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
          'Your Cart',
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ticket Summary',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context); // or implement real clear
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Cart cleared')));
                },
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
                label: const Text(
                  'Clear Cart',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Order Summary",
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cart Items
                  ...widget.cartItems.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    final isEntryTicket = item.title == "Entry Ticket";

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Material(
                        elevation: 1,
                        shadowColor: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Index circle
                                    // Container(
                                    //   width: 32,
                                    //   height: 32,
                                    //   alignment: Alignment.center,
                                    //   decoration: BoxDecoration(
                                    //     shape: BoxShape.circle,
                                    //     color: Colors.blue.shade100,
                                    //   ),
                                    //   child: Text(
                                    //     "$idx",
                                    //     style: TextStyle(
                                    //       color: Colors.blue.shade800,
                                    //       fontWeight: FontWeight.bold,
                                    //     ),
                                    //   ),
                                    // ),
                                    // const SizedBox(width: 16),

                                    // Main content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (item.subtitle != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              item.subtitle!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],

                                          const SizedBox(height: 12),

                                          // Time & Quantity row
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_filled,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                item.timeSlot,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "Qty: ${item.quantity}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blueGrey[800],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          // Chips & prices
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      item.subCategory ==
                                                          "Normal Ticket"
                                                      ? Colors.grey[300]
                                                      : Colors.blue[100],
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  item.subCategory,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        item.subCategory ==
                                                            "Normal Ticket"
                                                        ? Colors.black87
                                                        : Colors.blue[900],
                                                  ),
                                                ),
                                              ),
                                              if (item.subCategoryDetail !=
                                                  null)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.purple[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    item.subCategoryDetail!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.purple[800],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Base",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Text(
                                                    "₹${item.basePrice.toStringAsFixed(0)}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                "₹${item.totalPrice.toStringAsFixed(2)}",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[900],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Delete button (top-right)
                              if (!isEntryTicket)
                                Positioned(
                                  top: 8,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      color: Colors.redAccent,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      // ignore: collection_methods_unrelated_type
                                      setState(() {
                                        widget.cartItems.removeAt(idx - 1);
                                      });
                                      
                                    },
                                    tooltip: "Remove item",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Grand Total Section
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Grand Total",
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
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Proceeding to Checkout...")),
                  );
                  // TODO: navigate to payment / details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CheckoutScreen(cartItems: widget.cartItems),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Proceed to Checkout →",
                  style: GoogleFonts.roboto(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
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
}
