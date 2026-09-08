import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'platform_service_contracts.dart';

final class NativePrintService implements PrintService {
  const NativePrintService();
  @override
  Future<bool> printPdf(
          {required Uint8List bytes,
          required String jobName,
          double? pageWidth,
          double? pageHeight}) =>
      Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: jobName,
          format:
              PdfPageFormat(pageWidth ?? 612, pageHeight ?? 792, marginAll: 0),
          dynamicLayout: false,
          usePrinterSettings: false);
}
