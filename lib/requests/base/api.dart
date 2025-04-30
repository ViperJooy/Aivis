import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  /// 服务器地址
  static const String kBaseUrl = "https://api.pexels.com/";

  /// Api密钥
  static String kApiKey = dotenv.env['APIKEY'] ?? "";
}
