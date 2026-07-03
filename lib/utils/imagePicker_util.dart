import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();
  static Future<XFile?> openCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
  }
}
