import 'dart:io';

import 'package:image_picker/image_picker.dart';

final _picker = ImagePicker();

/// Kamera veya galeriden tek goruntu sec (orijinal kalite).
Future<File?> pickImage(ImageSource source) async {
  final xfile = await _picker.pickImage(
    source: source,
  );
  if (xfile == null) return null;
  return File(xfile.path);
}

/// Galeriden birden fazla goruntu sec (orijinal kalite).
Future<List<File>> pickMultipleImages() async {
  final xfiles = await _picker.pickMultiImage();
  return xfiles.map((xf) => File(xf.path)).toList();
}
