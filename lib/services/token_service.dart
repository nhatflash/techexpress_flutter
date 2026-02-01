import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {

  String getRoleFromToken(String token) {
    Map<String, dynamic> decoded = JwtDecoder.decode(token);
    return decoded['role'];
  }

  String getEmailFromToken(String token) {
    Map<String, dynamic> decoded = JwtDecoder.decode(token);
    return decoded['email'];
  }
}