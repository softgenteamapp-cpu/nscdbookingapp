import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nscd_app_for_booking/Constant/custom_widget.dart';
import 'package:nscd_app_for_booking/utils/l10n/app_localizations.dart';
import 'package:nscd_app_for_booking/View/lang.dart';

import 'package:nscd_app_for_booking/View/ticket.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isExpanded = false;
  List<String> items = [
    "Entry Ticket",
    "Holo Show - Fourth Floor",
    "Science show - Second Floor",
    "3D AUDI-1 - Second Floor",
    "Science On Sphere - Second Floor",
  ];
  List<String> images = [
    "assets/images/bookTicket.jpg",
    "assets/images/holoShow.jpg",
    "assets/images/scienceShow.png",
    "assets/images/3dshow.png",
    "assets/images/scienceOnSphere.jpeg",
  ];
  String _getPrice(String name) {
    switch (name.trim()) {
      case "Entry Ticket":
        return "Entry Fee ₹80";
      case "Holo Show - Fourth Floor":
        return "Visitors Fee ₹60";
      case "Science show - Second Floor":
        return "Visitors Fee ₹20";
      case "3D AUDI-1 - Second Floor":
        return "Visitors Fee ₹35";
      case "Science On Sphere - Second Floor":
        return "Visitors Fee ₹50";

      default:
        return "";
    }
  }

  List<RecentVisit> recentVisits = [
    RecentVisit(
      showName: "Holo Show - Fourth Floor",
      image: "assets/images/holoShow.jpg",
      price: "Visitors Fee ₹50",
      visitedAt: DateTime.now().subtract(const Duration(hours: 2)),
      location: "Fourth Floor",
    ),
    RecentVisit(
      showName: "Entry Ticket",
      image: "assets/images/scienceShow.png",
      price: "Entry Fee ₹80",
      visitedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    // Add more dynamically from user history (Firestore, Hive, SharedPreferences, etc.)
  ];
  String _getPriceForCategory(String category) {
    switch (category) {
      case "General":
        return "₹80";
      case "Child":
        return "₹50";
      case "Senior":
        return "₹40";
      case "School":
        return "₹30 / student";
      default:
        return "—";
    }
  }

  DateTime? selectedDate;

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final heightSize = MediaQuery.of(context).size.height;
    final widthSize = MediaQuery.of(context).size.width;
    final appLoc = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.lightBlue[50],
            title: Row(
              mainAxisAlignment: .center,
              children: [
                MyCustomwidget.myText(text1: appLoc.bookticket, text2: "NSCD"),
                const Spacer(),

                LanguageSwitch(),
              ],
            ),
            centerTitle: true,
            floating: true,
            surfaceTintColor: Colors.transparent,
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: heightSize * 0.14, // ← give enough vertical space
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                itemCount: items.length, // better than hard-coded 6
                itemBuilder: (context, index) {
                  final name = items[index];
                  final price = _getPrice(name);

                  return GestureDetector(
                    onTap: () {
                      print("Tapped on $name");

                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          String? selectedCategory;
                          DateTime? selectedDate;

                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text(
                                  "Book Your Visit",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Visitor Category Dropdown
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: "Visitor Category",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                      ),
                                      hint: const Text("Select category"),
                                      value: selectedCategory,
                                      items: const [
                                        DropdownMenuItem(
                                          value: "General",
                                          child: Text("General"),
                                        ),
                                        DropdownMenuItem(
                                          value: "School",
                                          child: Text("School Group"),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setDialogState(() {
                                          selectedCategory = value;
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // 2. Date Picker Field
                                    InkWell(
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                              context: dialogContext,
                                              initialDate:
                                                  selectedDate ??
                                                  DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(
                                                const Duration(days: 365),
                                              ),
                                            );

                                        if (picked != null) {
                                          setDialogState(() {
                                            selectedDate = picked;
                                          });
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: "Visit Date",
                                          hintText: "Select date",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          suffixIcon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 16,
                                              ),
                                        ),
                                        child: Text(
                                          selectedDate == null
                                              ? "Select date"
                                              : "${selectedDate!.day.toString().padLeft(2, '0')}-"
                                                    "${selectedDate!.month.toString().padLeft(2, '0')}-"
                                                    "${selectedDate!.year}",
                                          style: TextStyle(
                                            color: selectedDate == null
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Optional: Show preview/price if you want
                                    if (selectedCategory != null)
                                      Text(
                                        "Selected: $selectedCategory",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        (selectedCategory != null &&
                                            selectedDate != null)
                                        ? () {
                                            final formattedDate =
                                                "${selectedDate!.day.toString().padLeft(2, '0')}-"
                                                "${selectedDate!.month.toString().padLeft(2, '0')}-"
                                                "${selectedDate!.year}";

                                            Navigator.pop(dialogContext);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    TicketSelectionPage(
                                                      selectedCategory:
                                                          selectedCategory!,
                                                      selectedDate:
                                                          selectedDate!,
                                                    ),
                                              ),
                                            );

                                            // ← Add your real booking logic here
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlue[50],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text("Book Now"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },

                    // ── The rest of your card remains the same ──
                    child: Container(
                      width: heightSize * 0.28,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            child: Image.asset(
                              images[index],
                              width: heightSize * 0.11,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(
                                  //   name,
                                  //   maxLines: 2,
                                  //   overflow: TextOverflow.ellipsis,
                                  //   style: GoogleFonts.roboto(
                                  //     fontSize: 13,
                                  //     fontWeight: FontWeight.w700,
                                  //     height: 1.2,
                                  //   ),
                                  // ),
                                  MyCustomwidget.myText(
                                    text1: name,
                                    txtColor1: Colors.grey.shade500,
                                    fontSize1: 13,
                                    fontWeight1: FontWeight.w700,
                                  ),
                                  const SizedBox(height: 4),
                                  if (price.isNotEmpty)
                                    // Text(
                                    //   price,
                                    //   style: GoogleFonts.roboto(
                                    //     fontSize: 13,
                                    //     fontWeight: FontWeight.w600,
                                    //     color: Colors.green.shade700,
                                    //   ),
                                    // ),
                                    MyCustomwidget.myText(
                                      text1: price,
                                      txtColor1: Colors.green.shade700,
                                      fontSize1: 14,
                                      fontWeight1: FontWeight.w600,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "More content here...",
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),

          // i want to show upcoming envents in the future, so i will add more slivers here
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    "Featured Shows & Experiences",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: heightSize * 0.22, // adjust — make taller than before
                  child: CarouselSlider.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index, realIndex) {
                      final name = items[index];
                      final price = _getPrice(
                        name,
                      ); // reuse your helper or model

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Image takes most of the space
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Details section
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (price.isNotEmpty)
                                      Text(
                                        price,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: heightSize * 0.22,
                      viewportFraction:
                          1, // shows part of next/prev → nice peek effect
                      enlargeCenterPage:
                          false, // center item bigger & highlighted
                      // how much bigger center is
                      autoPlay: true, // auto slides
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        microseconds: 100,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      scrollDirection: Axis.horizontal,
                      padEnds: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(padding: const EdgeInsets.symmetric(vertical: 12)),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Recent Visits",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (recentVisits.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        "No recent visits yet.\nExplore some shows!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true, // important in CustomScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // disable nested scroll
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recentVisits.length,
                    itemBuilder: (context, index) {
                      final visit = recentVisits[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            // Optional: Navigate to details / re-open show info
                          },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: Image.asset(
                                  visit.image,
                                  width: 100, // fixed width for consistency
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        visit.showName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        visit.price,
                                        style: GoogleFonts.roboto(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            visit.timeAgo,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (visit.location != null) ...[
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              visit.location!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentVisit {
  final String showName; // e.g. "Holo Show - Fourth Floor"
  final String image; // asset path
  final String price; // e.g. "Visitors Fee ₹50"
  final DateTime visitedAt; // timestamp of visit
  final String? location; // optional: "Second Floor"

  RecentVisit({
    required this.showName,
    required this.image,
    required this.price,
    required this.visitedAt,
    this.location,
  });

  // Helper to format time ago (you can use intl or timeago package for better "2h ago")
  String get timeAgo {
    final diff = DateTime.now().difference(visitedAt);
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }
}
