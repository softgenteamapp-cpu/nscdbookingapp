import 'package:flutter/material.dart';
import 'package:nscd_app_for_booking/language_provider/lang_provider.dart';
import 'package:provider/provider.dart';

class LanguageSwitch extends StatefulWidget {
  const LanguageSwitch({super.key});

  @override
  State<LanguageSwitch> createState() => _LanguageSwitchState();
}

class _LanguageSwitchState extends State<LanguageSwitch> {
  bool isEnglish = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 90,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          /// Sliding Selector
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isEnglish ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 45,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          /// Text Buttons
          Row(
            children: [
              /// HI
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => isEnglish = false);
                    context.read<LangProvider>().changeLanguage('hi');
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isEnglish ? Colors.black54 : Colors.white,
                      ),
                      child: const Text("HI"),
                    ),
                  ),
                ),
              ),

              /// EN
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => isEnglish = true);
                    context.read<LangProvider>().changeLanguage('en');
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isEnglish ? Colors.white : Colors.black54,
                      ),
                      child: const Text("EN"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
