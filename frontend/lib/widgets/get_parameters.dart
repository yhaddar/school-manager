// This file provides a helper for Get.parameters access
// Note: In most cases, use Get.parameters directly as shown:
// final id = Get.parameters['id'];
import 'package:get/get.dart';

class GetParameters {
  static Map<String, String?> get parameters => Get.parameters.map((key, value) => MapEntry(key, value));
}
