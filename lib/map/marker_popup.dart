import 'package:expo_nomade/map/image_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class MarkerPopup extends StatelessWidget {
  const MarkerPopup({super.key, required this.data, required this.URLS});

  final List<MapEntry<String, String>> data;
  late List<String> URLS = [];

  double calculateFontSize(BuildContext context, double baseFontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = math.min(1.5, screenWidth / 400);

    return baseFontSize * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    double dynamicLargeFontSize = calculateFontSize(context, 20);
    double dynamicBaseFontSize = calculateFontSize(context, 15);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Slightly larger radius for a modern look
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // More symmetrical padding
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible( // For preventing overflow
                  child: Text(
                    data[0].value,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.oswald(
                      fontSize: dynamicLargeFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],  // Darker shade for more contrast
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.grey[600],
                  splashRadius: 20.0,  // Gives a compact feel when pressed
                ),
              ],
            ),
            SizedBox(height: 15.0),
            if (URLS != null && URLS!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ImageSlider(imageUrls: URLS),
              ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: data.length - 1,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[100], // Lighter card color for a softer look
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                      title: Text(
                        data[index + 1].key,
                        style: GoogleFonts.cabin(
                          fontSize: dynamicBaseFontSize,
                          fontWeight: FontWeight.w600, // Slightly less boldness for a cleaner look
                        ),
                      ),
                      subtitle: Text(
                        data[index + 1].value,
                        style: GoogleFonts.cabin(
                          fontSize: dynamicBaseFontSize - 2,
                          color: Colors.grey[700], // A bit darker for better readability
                        ),
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
