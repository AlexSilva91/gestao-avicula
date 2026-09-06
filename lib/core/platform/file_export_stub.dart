import 'dart:io';
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

  Future<String> shareText(String filename, String content) async {
    final path = await saveText(filename, content);
    await SharePlus.instance.share(
      ShareParams(
        title: 'Cópia de segurança GRANJA SELETO',
        subject: 'Cópia de segurança GRANJA SELETO',
        text: 'Cópia de segurança gerada pelo GRANJA SELETO.',
        files: [XFile(path, mimeType: 'application/json')],
      ),
    );
    return path;
  }
}
