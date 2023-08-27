import 'package:expo_nomade/map/image_slider.dart';
import 'package:flutter/material.dart';

class MarkerPopup extends StatelessWidget {
  const MarkerPopup({super.key, required this.data});

  final List<MapEntry<String, String>> data;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Nom de l\'objet'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
          child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            const Align(
                alignment: Alignment.center,
                child: ImageSlider(
                  imageUrls: [
                    'https://clipart-library.com/data_images/320465.png',
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Sign-check-icon.png/640px-Sign-check-icon.png',
                    'https://img.lovepik.com/element/40116/9419.png_300.png',
                    'https://via.placeholder.com/150?text=Image%201'
                  ],
                )),
            for (var item in data)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ],
              ),
          ],
        ),
      )),
    );
  }
}
