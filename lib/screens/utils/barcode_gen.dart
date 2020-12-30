import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';

class BarcodeGen {
  final String itemName;
  final String barcodeData;

  BarcodeGen({this.barcodeData, this.itemName});

  final pdf = pw.Document();

  writeOnPdf() {
    print(barcodeData);
    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat(
              1.5 * PdfPageFormat.inch, PdfPageFormat.inch,
              marginAll: 5),
          build: (pw.Context context) {
            return pw.Column(children: [
              pw.Expanded(
                child: pw.BarcodeWidget(
                  data: barcodeData,
                  barcode: pw.Barcode.code128(),
                ),
              ),
              pw.Text(itemName),
            ]);
          }),
    );
  }

  Future writeAndSavePdf() async {
    await writeOnPdf();
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        Directory docDir = await getDownloadsDirectory();
        print(docDir.path);
      }
    } catch (e) {
      /// Exception means that the platform is Web.
      final bytes = pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = "$itemName-barcode.pdf";
      html.document.body.children.add(anchor);
      anchor.click();
      html.document.body.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }
}
