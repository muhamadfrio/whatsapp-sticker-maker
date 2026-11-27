import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildLoading(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Stack(
    children: [
      ModalBarrier(
        color: Colors.black.withOpacity(0.35),
        dismissible: false,
      ),
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xCC2C2C2E)
                    : const Color(0xCCF2F2F7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0x38FFFFFF) : const Color(0x1F000000),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(
                    radius: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memproses latar belakang...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
