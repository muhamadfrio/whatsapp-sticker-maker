import 'package:flutter/material.dart';
import 'package:whatsappstickermaker/common/theme/app_theme.dart';

class SafeAreaScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  const SafeAreaScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark
        ? AppTheme.darkSystemGroupedBackground
        : AppTheme.systemGroupedBackground;

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? defaultBg,
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
