import 'dart:convert';
void main() {
  String roomId = 'vc_direct_WhKqC4PFEqStf2IfxFreyHhtyeO2_Y2dBMMm12hVQwO79f0Fpcl28lB42';
  int safeRingEpochMs = 1776409962502;
  String callAttemptKey = '$roomId#$safeRingEpochMs';

  bool _isValidCallKitUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-'
      r'[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(value.trim());
  }

  BigInt _fnv1a64(List<int> bytes, int offsetBasis) {
    final BigInt prime = BigInt.from(0x100000001b3);
    final BigInt mask = BigInt.parse("FFFFFFFFFFFFFFFF", radix: 16);
    BigInt hash = BigInt.from(offsetBasis) & mask;

    for (final int byte in bytes) {
      hash = (hash ^ BigInt.from(byte)) * prime;
      hash &= mask;
    }

    return hash;
  }

  String _hex64(BigInt value) {
    return value.toRadixString(16).padLeft(16, '0');
  }

  final List<int> bytes = utf8.encode(callAttemptKey);
  final BigInt hash1 = _fnv1a64(bytes, 0xcbf29ce484222325);
  final BigInt hash2 = _fnv1a64(bytes, -8911036328659649244);
  final String hex = '${_hex64(hash1)}${_hex64(hash2)}';

  final List<String> chars = hex.split('');
  chars[12] = '4';

  final int variantNibble = int.parse(chars[16], radix: 16);
  chars[16] = ((variantNibble & 0x3) | 0x8).toRadixString(16);

  final String generatedUuid =
      '${chars.take(8).join()}-${chars.skip(8).take(4).join()}-'
      '${chars.skip(12).take(4).join()}-${chars.skip(16).take(4).join()}-'
      '${chars.skip(20).take(12).join()}';
  
  print("Generated UUID: $generatedUuid");
  print("Is valid base? ${_isValidCallKitUuid(generatedUuid)}");
  
  if (_isValidCallKitUuid(generatedUuid)) {
    print("Used UUID: $generatedUuid");
  } else {
    final String hashHex =
        callAttemptKey.hashCode.abs().toRadixString(16).padLeft(8, '0');
    print("Fallback UUID: $hashHex-0000-4000-8000-000000000000");
  }
}
