import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileExportService {
  Future<String> saveText(String filename, String content) async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory()
        : await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content, flush: true);
    return file.path;
  }

  Future<String> saveBytes(String filename, Uint8List bytes) async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory()
        : await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String> openBytes(
    String filename,
    Uint8List bytes, {
    String mimeType = 'application/pdf',
  }) async {
    final path = await saveBytes(filename, bytes);
    final result = await OpenFilex.open(path, type: mimeType);
    if (result.type != ResultType.done) {
      await SharePlus.instance.share(
        ShareParams(
          title: filename,
          subject: filename,
          files: [XFile(path, mimeType: mimeType)],
        ),
      );
    }
    return path;
  }

  Future<String> shareText(String filename, String content) async {
    final path = await saveText(filename, content);
    await SharePlus.instance.share(
      ShareParams(
        title: 'Cópia de segurança SELETO',
        subject: 'Cópia de segurança SELETO',
        text: 'Cópia de segurança gerada pelo SELETO.',
        files: [XFile(path, mimeType: 'application/json')],
      ),
    );
    return path;
  }
}
