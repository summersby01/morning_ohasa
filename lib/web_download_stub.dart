import 'dart:typed_data';

Future<void> downloadPngBytesOnWeb(Uint8List bytes, String filename) async {
  throw UnsupportedError('Web download is only available on Flutter web.');
}
