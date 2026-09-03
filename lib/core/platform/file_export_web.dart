// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

class FileExportService {
  Future<String> saveText(String filename, String content) async {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'application/json;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    return filename;
  }

  Future<String> shareText(String filename, String content) =>
      saveText(filename, content);
}
