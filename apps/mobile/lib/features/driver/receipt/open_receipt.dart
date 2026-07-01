import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Écrit les octets du reçu PDF dans le cache de l'app et l'ouvre avec le
/// lecteur natif de l'appareil.
Future<void> openReceiptPdf({
  required List<int> bytes,
  required String reference,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/recu-$reference.pdf');
  await file.writeAsBytes(bytes, flush: true);
  await OpenFilex.open(file.path);
}
