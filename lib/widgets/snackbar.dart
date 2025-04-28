import 'package:flutter/material.dart';

void showTopSnackBar(BuildContext context, String message) {
  OverlayState? overlay = Overlay.of(context);

  late OverlayEntry overlayEntry; // Declare the variable late so it can be assigned later.

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 10, // Adds padding for status bar
      left: 10,
      right: 10,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  
  // Auto-dismiss after 2 seconds
  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
