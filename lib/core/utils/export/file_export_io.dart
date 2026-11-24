import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<bool> saveFile(String fileName, Uint8List bytes, String mimeType) async {
  final result = await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
      fileNameOverrides: [fileName],
      subject: fileName,
    ),
  );
  return result.status != ShareResultStatus.unavailable;
}
