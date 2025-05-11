import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

String formatWei(dynamic value) {
  if (value == null) return '0';

  try {
    final bigInt = BigInt.parse(value.toString());
    final ethValue = bigInt / BigInt.from(10).pow(18);

    if (ethValue < 0.0001 && bigInt > BigInt.zero) {
      return '< 0.0001 ETH';
    }

    final format = NumberFormat.currency(
      symbol: 'ETH ',
      decimalDigits: 4,
    );
    return format.format(ethValue);
  } catch (e) {
    return '$value Wei';
  }
}

toast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}
