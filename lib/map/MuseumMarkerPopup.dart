import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class MuseumMarkerPopup extends StatelessWidget {
  const MuseumMarkerPopup({super.key, required this.data});

  final List<MapEntry<String, String>> data;

  double calculateFontSize(BuildContext context, double baseFontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = math.min(1.3, screenWidth / 400);

    return baseFontSize * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    double dynamicLargeFontSize = calculateFontSize(context, 18);
    double dynamicBaseFontSize = calculateFontSize(context, 13);

    return Dialog(
      backgroundColor: Colors.white,  // Set a clean white background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),  // A smoother border radius
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(  // Ensure text doesn't overflow
                  child: Text(
                    data[0].value,
                    overflow: TextOverflow.ellipsis,  // If text is too long, it'll end in '...'
                    style: GoogleFonts.oswald(
                      fontSize: dynamicLargeFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.grey[600],  // More neutral color for the icon
                  splashRadius: 20.0,  // A smaller visual feedback radius
                  iconSize: 24.0,  // A slightly bigger icon size
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: data.length - 1,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[100],  // Lighter card for a modern look
                    elevation: 2.0,  // Reduced elevation for subtleness
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),  // Rounded edges for the card
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5.0),  // Slightly reduced margin
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      title: Text(
                        data[index + 1].key,
                        style: GoogleFonts.cabin(
                          fontSize: dynamicBaseFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        data[index + 1].value,
                        style: GoogleFonts.cabin(fontSize: dynamicBaseFontSize - 2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
