import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;
import 'package:store_manager/models/bills_model/bill_model.dart';

class PdfFunctions {
  final List<BillItem> billItemsList;
  final int invoiceNo;
  final String invoiceDate;
  final String customerName;
  final double totalAmt;
  final double amtReceived;
  final double amtBalance;

  final pdf = pw.Document();

  PdfFunctions({
    this.billItemsList,
    this.invoiceNo,
    this.invoiceDate,
    this.customerName,
    this.totalAmt,
    this.amtReceived,
    this.amtBalance,
  });
  writeOnPdf() {
    int counter = 0;
    List<pw.TableRow> tableRowList = [
      pw.TableRow(
        children: [
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text("#"),
          ),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text("Item Name"),
          ),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text("Quantity"),
          ),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text("Price / Unit"),
          ),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text("Amount"),
          ),
        ],
      ),
    ];

    List<pw.TableRow> tableRows = billItemsList.map((offBillItem) {
      counter++;
      return pw.TableRow(
        children: [
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text("$counter"),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 5),
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text("${offBillItem.name}"),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 5),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("${offBillItem.qty}"),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 5),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("${offBillItem.pricePerUnit}"),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 5),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("${offBillItem.amt}"),
            ),
          ),
        ],
      );
    }).toList();

    tableRowList.addAll(tableRows);

    pdf.addPage(
      pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context pwContext) {
            return [
              pw.Column(
                children: [
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text("COMPANY NAME"),
                  ),
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text("Phone No: 9999999999"),
                  ),
                  ////////////////////////
                  pw.SizedBox(height: 10),
                  pw.Text("Tax Invoice"),
                  ////////////////////////
                  pw.SizedBox(height: 10),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Bill To:"),
                        pw.Text("Invoice No: $invoiceNo"),
                      ]),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(customerName),
                      pw.Text("Date: $invoiceDate"),
                    ],
                  ),
                  //////// Items Table.
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: tableRowList,
                  ),
                ],
              ),
              ///////////////////////
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Flexible(
                    flex: 1,
                    child: pw.Container(),
                  ),
                  pw.Flexible(
                    flex: 1,
                    child: pw.Column(
                      children: [
                        ///// Subtotal Row
                        // pw.Row(
                        //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     pw.Text("Sub total"),
                        //     pw.Text("Rs. $_totalAmt"),
                        //   ],
                        // ),
                        ///// Total Row
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Total"),
                            pw.Text("Rs. $totalAmt"),
                          ],
                        ),
                        ///// Received Row
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Received"),
                            pw.Text("Rs. $amtReceived"),
                          ],
                        ),
                        ///// Balance Row
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Balance"),
                            pw.Text("Rs. $amtBalance"),
                          ],
                        ),
                        ///////// Divider
                        pw.Divider(),
                        ///////////////
                        pw.SizedBox(height: 5),
                        pw.Text("For CompanyName"),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          }),
    );
  }

  Future writeAndSavePdf() async {
    await writeOnPdf();
    final bytes = pdf.save();
    String fileName = "$invoiceNo-$customerName-$invoiceDate.pdf";
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // final Directory docDir = await getApplicationDocumentsDirectory();
        // final String path = "${docDir.path}/$fileName";
        // Do nothing!!!
      }
    } catch (e) {
      /// Exception means that the platform is Web.
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body.children.add(anchor);
      anchor.click();
      html.document.body.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  Future writeAndPrintPdf() async {
    await writeOnPdf();
    final bytes = pdf.save();
    // final blob = html.Blob([bytes], 'application/pdf');
    // final String url = html.Url.createObjectUrlFromBlob(blob);
    // http.Response response = await http.get(url);
    // var pdfData = response.bodyBytes;
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  Future writeAndSaveAndPrintPdf() async {
    await writeAndSavePdf();
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        Directory docDir = await getDownloadsDirectory();
        print(docDir.path);
      }
    } catch (e) {
      /// Exception means that the platform is Web.
      final bytes = pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final String url = html.Url.createObjectUrlFromBlob(blob);
      http.Response response = await http.get(url);
      var pdfData = response.bodyBytes;
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfData);
    }
  }
}
