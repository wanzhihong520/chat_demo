import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();
  static Future<XFile?> openCamera({bool isVideo = false}) async {
    if (isVideo) {
      return await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );
    } else {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
    }
  }
}
