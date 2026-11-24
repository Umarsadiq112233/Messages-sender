import 'dart:typed_data';

import 'file_export_io.dart' if (dart.library.js_interop) 'file_export_web.dart' as impl;

/// Saves / shares a generated file.
/// Web: downloads it in the browser. Mobile: opens the share sheet
/// (WhatsApp, email…) so the report can be sent straight to the client.
abstract final class FileExport {
  static Future<bool> save({required String fileName, required Uint8List bytes, required String mimeType}) =>
      impl.saveFile(fileName, bytes, mimeType);
}
