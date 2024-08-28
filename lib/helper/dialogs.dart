import 'package:flutter/material.dart';

class Dialogs {
  //static members means they are created only once and can be accessed without class object
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue.withOpacity(0.8),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showProgressIndicator(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
