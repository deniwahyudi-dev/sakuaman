import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RupiahInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');
    
    // Batasi 12 digit
    final String limitedDigits = digitsOnly.substring(0, digitsOnly.length.clamp(0, 12));
    
    final int value = int.parse(limitedDigits);
    final String newText = _formatter.format(value);

    // Hitung posisi kursor
    int selectionIndex = newValue.selection.end;
    final int oldLength = oldValue.text.length;
    final int newLength = newText.length;
    
    // Penyesuaian kursor sederhana untuk pemisah ribuan
    final int diff = newLength - oldLength;
    selectionIndex += diff;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selectionIndex.clamp(0, newText.length),
      ),
    );
  }
}
