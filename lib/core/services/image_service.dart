import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<Uint8List?> pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
      if (file == null) return null;
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Image pick error: $e');
      return null;
    }
  }
}
