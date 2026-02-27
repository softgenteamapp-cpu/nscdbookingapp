import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyCustomwidget {
  // my text widget
  ///
  static Widget myText({
    TextStyle? style,
    String? text1,
    String? text2,
    Color? txtColor1,
    Color? txtColor2,
    double? fontSize1,
    double? fontSize2,
    FontWeight? fontWeight2,
    FontWeight? fontWeight1,
  }) {
    return RichText(
      text: TextSpan(
        text: text1,
        style: GoogleFonts.openSans(
          color: txtColor1 ?? Colors.black,
          fontSize: fontSize1 ?? 18,
          fontWeight: fontWeight1 ?? FontWeight.bold,
        ).merge(style),
        children: [
          TextSpan(
            text: text2,
            style: GoogleFonts.inter(
              color: txtColor2 ?? Colors.blue,
              fontSize: fontSize2 ?? 8,
              fontWeight: fontWeight2 ?? FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
