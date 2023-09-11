import 'dart:io';

import 'package:flutter/material.dart';

class CircularProfilePicture extends StatelessWidget {
  final double radius;
  final File? imageFile;
  final VoidCallback onPressed;

  CircularProfilePicture({
    required this.radius,
    required this.imageFile,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: UniqueKey(),
      onTap: onPressed,
      child: ClipOval(
        child: imageFile != null
            ? Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(imageFile!), // Use your image URL here
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
