import 'package:flutter/material.dart';

import '../../../shared/app_colors.dart';

class CardItem extends StatelessWidget {
  final String title;
  final String info;
  final String imageUrl;

  const CardItem({
    Key? key,
    required this.title,
    required this.info,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: mainColor2.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8, 
      shadowColor: Colors.black.withOpacity(0.2),
    
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 150,
                  width: double.infinity,
                ),
              ),
            ),
            // Title section
            Padding(
              padding: const EdgeInsets.only(left: 12 , right: 12 , top: 12 , bottom: 6),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
              child: Text(
                info,
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor.withOpacity(0.85),
                  fontStyle: FontStyle.italic, 
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
