import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripePaymentReqHeader {
  static Map<String, String> toJson() {
    return <String, String>{
      'Authorization':
          'Bearer ${dotenv.env['"'
              "'STRIPE_SECRET_KEY'"
              '"']}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }
}
