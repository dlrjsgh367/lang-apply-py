import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfApi {
  static Future<File> generateCenteredText(String text) async {
    final pdf = Document();
    final customFont = Font.ttf(
        await rootBundle.load('assets/fonts/OpenSans_Condensed-Bold.ttf'));

    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return Center(
            child: Text(text, style: TextStyle(fontSize: 48, font: customFont)),
          );
        },
      ),
    );

    return saveDocument(name: 'my_example.pdf', pdf: pdf);
  }

  static Future<File> generateNormal(String title, List<pw.Widget> firstWidget) async {
    final pdf = Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(50, 20, 50, 20),
        build: (context) {
          return firstWidget;
        },
      ),
    );
    return saveDocument(name: '$title.pdf', pdf: pdf);
  }

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<Map<String, dynamic>> saveDocumentMap({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    return {
      "url": '${dir.path}/$name',
      "name": name,
      "bytes": bytes,
      "mime": 'application/pdf',
    };
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
