import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nscd_app_for_booking/View/cart/cart_page.dart';

class TicketSelectionPage extends StatefulWidget {
  final String selectedCategory;
  late DateTime selectedDate;

  TicketSelectionPage({
    super.key,
    required this.selectedCategory,
    required this.selectedDate,
  });

  @override
  State<TicketSelectionPage> createState() => _TicketSelectionPageState();
}

class _TicketSelectionPageState extends State<TicketSelectionPage> {
  // Show data
  final Map<String, Map<String, dynamic>> shows = {
    "Science On Sphere - Second Floor": {
      "duration": 25,
      "capacity": 100,
      "price": 50.0,
      "times": [
        "11:00 AM",
        "11:30 AM",
        "12:30 PM",
        "02:00 PM",
        "03:00 PM",
        "04:00 PM",
        "05:00 PM",
      ],
    },
    "3D AUDI-1 - Second Floor": {
      "duration": 12,
      "capacity": 50,
      "price": 35.0,
      "times": [
        "10:30 AM",
        "11:00 AM",
        "11:30 AM",
        "12:00 PM",
        "12:30 PM",
        "01:00 PM",
        "01:30 PM",
        "02:00 PM",
        "02:30 PM",
        "03:00 PM",
        "03:30 PM",
        "04:00 PM",
        "04:30 PM",
        "05:00 PM",
        "05:30 PM",
      ],
    },
    "Science Show - Second Floor": {
      "duration": 30,
      "capacity": 50,
      "price": 20.0,
      "times": ["10:30 AM", "12:30 PM", "03:00 PM", "03:30 PM", "04:00 PM"],
    },
    "Holo Show - Fourth Floor": {
      "duration": 15,
      "capacity": 50,
      "price": 60.0,
      "times": [
        "10:30 AM",
        "11:15 AM",
        "12:00 PM",
        "12:30 PM",
        "02:15 PM",
        "03:00 PM",
        "04:15 PM",
        "04:45 PM",
      ],
    },
    // Add more shows from the timetable as needed (Full Dome, Fantasy Ride, etc.)
  };

  // State for shows: qty and selected time
  final Map<String, int> showQtys = {};
  final Map<String, String?> showSelectedTimes = {};

  // Entry time slot (assuming one for all entry?)
  String? entryTimeSlot = "10:00 AM - 05:00 PM"; // Default from image

  double get totalPrice {
    double total = 0.0;

    // 1. Add price for all special category tickets
    subCategoryQtys.forEach((cat, qty) {
      if (qty > 0) {
        double pricePerTicket = subCategoryPrices[cat] ?? 0.0;
        total += qty * pricePerTicket;
      }
    });

    // 2. Calculate how many people are left (general entry)
    int specialCount = subCategoryQtys.values.fold(0, (sum, qty) => sum + qty);
    int generalActual = generalEntryQty - specialCount; // usually should be ≥ 0

    // Only charge general price for people who are NOT in special categories
    if (generalActual > 0) {
      total += generalActual * 80.0;
    } else if (generalActual < 0) {
      // Optional: log warning in debug mode
      // debugPrint("Warning: more special tickets than generalEntryQty");
    }

    // 3. Add shows (unchanged)
    double showsPrice = 0.0;
    showQtys.forEach((show, qty) {
      showsPrice += qty * (shows[show]?["price"] as double? ?? 0.0);
    });
    total += showsPrice;

    return total;
  }

  // Parse time to minutes since midnight
  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    int min = int.parse(hm[1]);
    if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12)
      hour += 12;
    return hour * 60 + min;
  }

  // Check if two time intervals overlap
  bool _intervalsOverlap(String time1, int dur1, String time2, int dur2) {
    int start1 = _timeToMinutes(time1);
    int end1 = start1 + dur1;
    int start2 = _timeToMinutes(time2);
    int end2 = start2 + dur2;
    return !(end1 <= start2 || end2 <= start1);
  }

  // Check for time conflicts
  Future<bool> _checkTimeConflict(String currentShow, String newTime) async {
    int dur = shows[currentShow]?["duration"] as int? ?? 0;
    for (var entry in showSelectedTimes.entries) {
      if (entry.key != currentShow && entry.value != null) {
        int otherDur = shows[entry.key]?["duration"] as int? ?? 0;
        if (_intervalsOverlap(newTime, dur, entry.value!, otherDur)) {
          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Time Conflict"),
              content: const Text(
                "You have already chosen this time earlier for another show. Do you want to proceed?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Proceed"),
                ),
              ],
            ),
          );
          return confirm ?? false;
        }
      }
    }
    return true;
  }

  Widget _buildStepper({
    required int value,
    required VoidCallback? onDecrease,
    required VoidCallback onIncrease,
    bool small = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: small ? 20 : 24,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: small ? 32 : 40,
              minHeight: small ? 32 : 40,
            ),
            icon: const Icon(Icons.remove),
            onPressed: onDecrease,
          ),
          SizedBox(
            width: small ? 32 : 44,
            child: Center(
              child: Text(
                "$value",
                style: TextStyle(fontSize: small ? 15 : 17),
              ),
            ),
          ),
          IconButton(
            iconSize: small ? 20 : 24,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: small ? 32 : 40,
              minHeight: small ? 32 : 40,
            ),
            icon: const Icon(Icons.add),
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }

  int generalEntryQty = 0;
  final Map<String, int> subCategoryQtys = {
    "BPL Card Holder": 0,
    "Physically Challenged": 0,
    "Serving Defence Personnel": 0,
    "ICOM Member": 0,
    "Children Below 90 cm Height": 0,
  };

  final Map<String, double> subCategoryPrices = {
    "BPL Card Holder": 20.0,
    "Physically Challenged": 0.0,
    "Serving Defence Personnel": 0.0,
    "ICOM Member": 40.0,
    "Children Below 90 cm Height": 0.0,
  };

  // 2. Total visitors & price calculation (correct logic)
  int get totalVisitors {
    // Total log = general + special categories (lekin special zyada nahi ho sakte general se)
    return generalEntryQty;
    // Note: hum special ko general ke andar hi count kar rahe hain
    // special categories general tickets ko replace karti hain, extra nahi add karti
  }

  double get entryTotalPrice {
    // Sabse pehle free wale categories ko priority do
    int freeCount =
        subCategoryQtys["Physically Challenged"]! +
        subCategoryQtys["Serving Defence Personnel"]! +
        subCategoryQtys["Children Below 90 cm Height"]!;
    // subCategoryQtys["ICOM Member"]
    // ;

    // BPL wale discount wale
    int bplCount = subCategoryQtys["BPL Card Holder"]!;
    int iconCount = subCategoryQtys["ICOM Member"]!;

    // Kitne log full price denge
    int fullPriceCount = generalEntryQty - freeCount - bplCount - iconCount;

    // Agar negative aa jaye to 0 kar do
    if (fullPriceCount < 0) fullPriceCount = 0;

    double total = 0.0;
    total += fullPriceCount * 80.0;
    total += bplCount * 20.0;
    total += iconCount * 40.0;
    // free wale 0 rahega

    return total;
  }

  @override
  void initState() {
    super.initState();
    // Initialize qtys
    for (var show in shows.keys) {
      showQtys[show] = 0;
      showSelectedTimes[show] = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Text(
          "Book Ticket",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visitor Category and Date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Choose Visitor Category"),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        value: widget.selectedCategory,
                        items: [
                          DropdownMenuItem(
                            value: "General",
                            child: Text("General Visitor"),
                          ),
                          DropdownMenuItem(
                            value: "School",
                            child: Text("School Group"),
                          ),
                        ],
                        onChanged: null, // Disabled, as pre-selected
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: widget.selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );

                          if (picked != null) {
                            setState(() {
                              widget.selectedDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Visit Date",
                            hintText: "Select date",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            widget.selectedDate == null
                                ? "Select date"
                                : "${widget.selectedDate.day.toString().padLeft(2, '0')}-"
                                      "${widget.selectedDate.month.toString().padLeft(2, '0')}-"
                                      "${widget.selectedDate.year}",
                            style: TextStyle(
                              color: widget.selectedDate == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ExpansionTile(
              initiallyExpanded:
                  generalEntryQty > 0 ||
                  subCategoryQtys.values.any((q) => q > 0),
              leading: Checkbox(
                value: generalEntryQty > 0,
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true && generalEntryQty == 0) {
                      generalEntryQty = 1;
                    } else if (checked == false) {
                      generalEntryQty = 0;
                      subCategoryQtys.updateAll((key, value) => 0);
                    }
                  });
                },
              ),
              title: Row(
                children: [
                  const Text(
                    "Entry Ticket",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (generalEntryQty > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "₹${entryTotalPrice.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: generalEntryQty > 0
                  ? Text(
                      "$generalEntryQty person${generalEntryQty > 1 ? 's' : ''}",
                    )
                  : const Text("Select number of visitors"),
              childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                // General Visitors (full price wale)
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "General Visitor (₹80)",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    _buildStepper(
                      value: generalEntryQty,
                      onDecrease: generalEntryQty > 0
                          ? () {
                              setState(() {
                                generalEntryQty--;
                                // Agar general kam ho gaya to special bhi adjust kar sakte ho
                                // ya warning dikha sakte ho
                              });
                            }
                          : null,
                      onIncrease: () => setState(() => generalEntryQty++),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Discounted / Free Categories
                Text(
                  "Special Categories (Discount / Free)",
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(height: 8),

                ...subCategoryQtys.entries.map((entry) {
                  final cat = entry.key;
                  final qty = entry.value;
                  final price = subCategoryPrices[cat]!;
                  final isFree = price == 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isFree
                                  ? Colors.green[800]
                                  : Colors.black87,
                              fontWeight: isFree
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        _buildStepper(
                          value: qty,
                          small: true,
                          onDecrease: qty > 0
                              ? () => setState(
                                  () => subCategoryQtys[cat] = qty - 1,
                                )
                              : null,
                          onIncrease: () {
                            final currentSpecial = subCategoryQtys.values.fold(
                              0,
                              (s, v) => s + v,
                            );
                            final newSpecial = currentSpecial - qty + (qty + 1);

                            if (newSpecial > generalEntryQty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Special category visitors cannot exceed total entry tickets",
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            setState(() => subCategoryQtys[cat] = qty + 1);
                          },
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 100,
                          child: Text(
                            isFree
                                ? "Free"
                                : "₹${price.toStringAsFixed(0)} × $qty",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isFree
                                  ? Colors.green[700]
                                  : Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Total Visitors: $generalEntryQty\n"
                    "Total Entry Amount: ₹${entryTotalPrice.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Shows as ExpansionTiles
            ...shows.keys.map((show) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.theaters,
                      color: Colors.blue.shade700,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    show,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "Select time & ticket quantity",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),

                  children: [
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // Duration pill
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    "${shows[show]!["duration"]}min ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey[800],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Capacity pill
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_alt_outlined,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    "${shows[show]!["capacity"]}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey[800],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Price pill
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "₹ ${shows[show]!["price"]}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey[800],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Quantity field in a pill
                        Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextFormField(
                            initialValue: (showQtys[show] ?? 0).toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 12),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              int newQty = int.tryParse(val) ?? 0;

                              if (newQty > totalVisitors) {
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text(
                                //       "Quantity cannot exceed total visitors",
                                //     ),
                                //   ),
                                // );
                                FlutterToastr.show(
                                  "Quantity cannot exceed total visitors",
                                  context,
                                  position: FlutterToastr.center,
                                  backgroundColor: Colors.lightBlue[500]!,
                                  duration: FlutterToastr.lengthLong,
                                  textStyle: TextStyle(color: Colors.white),
                                );
                                return;
                              }

                              setState(() => showQtys[show] = newQty);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Available times",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Time chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (shows[show]!["times"] as List<String>).map((
                        time,
                      ) {
                        bool isSelected = showSelectedTimes[show] == time;

                        return ChoiceChip(
                          label: Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue,
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (_) async {
                            if (isSelected) {
                              setState(() => showSelectedTimes[show] = null);
                              return;
                            }

                            bool noConflict = await _checkTimeConflict(
                              show,
                              time,
                            );
                            if (noConflict) {
                              setState(() => showSelectedTimes[show] = time);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            // Total Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("₹ ${totalPrice.toStringAsFixed(0)}"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child:
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Add to cart logic
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: Text(
                  //           "Added to Cart: ₹ ${totalPrice.toStringAsFixed(0)}",
                  //         ),
                  //       ),
                  //     );
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => CartPage()),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  //   child: const Text("Add to Cart"),
                  // ),
                  // Inside _TicketSelectionPageState
                  ElevatedButton(
                    onPressed: () {
                      if (generalEntryQty == 0) {
                        FlutterToastr.show(
                          "Please select at least one visitor",
                          context,
                          position: FlutterToastr.center,
                          backgroundColor: Colors.lightBlue[500]!,
                          duration: FlutterToastr.lengthLong,
                          textStyle: TextStyle(color: Colors.white),
                        );
                        return;
                      }

                      // Collect all cart items
                      final List<CartItem> cartItems = [];

                      // ── 1. Entry Ticket (special handling)
                      final int totalSpecial = subCategoryQtys.values.fold(
                        0,
                        (s, v) => s + v,
                      );
                      final int generalFullPriceCount =
                          generalEntryQty - totalSpecial;

                      // We show one consolidated "Entry Ticket" row (like your screenshot)
                      double entryTotal =
                          entryTotalPrice; // already calculated correctly

                      cartItems.add(
                        CartItem(
                          title: "Entry Ticket",
                          subtitle: "Entry Ticket / Event Pass",
                          timeSlot: entryTimeSlot ?? "10:00 AM - 05:00 PM",
                          quantity: generalEntryQty,
                          basePrice: 80.0,
                          subCategory: totalSpecial > 0
                              ? "Mixed / Discounted"
                              : "Normal Ticket",
                          subCategoryDetail: totalSpecial > 0
                              ? "Includes discounts/free"
                              : null,
                          totalPrice: entryTotal,
                        ),
                      );

                      // ── 2. Individual shows
                      showQtys.forEach((showName, qty) {
                        if (qty > 0) {
                          final selectedTime = showSelectedTimes[showName];
                          if (selectedTime == null) {
                            // Optional: warn user
                            return;
                          }

                          final showData = shows[showName]!;
                          final double pricePer = showData["price"] as double;

                          cartItems.add(
                            CartItem(
                              title: showName,
                              subtitle: "Entry Ticket / Event Pass",
                              timeSlot: selectedTime,
                              quantity: qty,
                              basePrice: pricePer,
                              subCategory:
                                  "Normal Ticket", // you can extend later
                              totalPrice: qty * pricePer,
                            ),
                          );
                        }
                      });

                      // Optional: check if cart is empty
                      if (cartItems.isEmpty ||
                          cartItems.every((i) => i.quantity == 0)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No tickets selected")),
                        );
                        return;
                      }

                      // Navigate with data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(cartItems: cartItems),
                        ),
                      );

                      // Optional success feedback
                      FlutterToastr.show(
                        "Proceed Add to Cart...",
                        context,
                        backgroundColor: Colors.lightBlue[200]!,
                        duration: FlutterToastr.lengthLong,
                        textStyle: TextStyle(color: Colors.white),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Add to Cart"),
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final String
  title; // e.g. "Entry Ticket" or "Science On Sphere - Second Floor"
  final String? subtitle; // e.g. "Entry Ticket / Event Pass"
  final String timeSlot;
  final int quantity;
  final double basePrice;
  final String subCategory; // "BPL Card Holder", "Normal Ticket", etc.
  final String? subCategoryDetail; // e.g. "×1 = ₹20" or null
  final double totalPrice;

  CartItem({
    required this.title,
    this.subtitle,
    required this.timeSlot,
    required this.quantity,
    required this.basePrice,
    required this.subCategory,
    this.subCategoryDetail,
    required this.totalPrice,
  });
}
