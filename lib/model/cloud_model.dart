import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  // بياناتك الحقيقية اللي بعتها
  static const String cloudName = "dtv72znzl";
  static const String uploadPreset =
      "nexus_preset"; // تأكد إنك سميته كدة وعملته Unsigned في الموقع

  final Dio _dio = Dio();

  Future<String?> uploadImage(File file) async {
    try {
      String url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      // تجهيز البيانات كأنها Form
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
        "upload_preset": uploadPreset,
      });

      // إرسال الطلب مع مراقبة التحدم (اختياري بس احترافي)
      Response response = await _dio.post(
        url,
        data: formData,
        onSendProgress: (sent, total) {
          print("Progress: ${(sent / total * 100).toStringAsFixed(0)}%");
        },
      );

      if (response.statusCode == 200) {
        // ده اللينك النهائي للصورة (Secure URL)
        return response.data['secure_url'];
      }
    } catch (e) {
      print("Error during Cloudinary upload: $e");
    }
    return null;
  }
}
