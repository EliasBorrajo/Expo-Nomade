import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  const ImageSlider({super.key, required this.imageUrls});

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.6);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double targetHeight = screenWidth * (1 / 4);
    double scale = 0.7; // Adjust the scale factor
    double adjustedHeight = targetHeight * scale;

    return SizedBox(
      height: adjustedHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return Transform.scale(
            alignment: Alignment.center, // Align images to the top
            scale: scale,
            child: Image.network(
              widget.imageUrls[index],
              fit: BoxFit.contain, // Fit the image within the constraints
              height: adjustedHeight, // Adjust the height
              width: screenWidth * scale, // Adjust the width
            ),
          );
        },
      ),
    );
  }
}
