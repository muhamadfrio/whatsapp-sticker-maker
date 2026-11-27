import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsappstickermaker/common/theme/app_theme.dart';
import 'package:whatsappstickermaker/module/sticker_maker/binding/sticker_maker_binding.dart';
import 'package:whatsappstickermaker/module/sticker_maker/screen/sticker_maker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WhatsApp Sticker Maker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: StickerMakerBinding(),
      home: const StickerMakerScreen(),
    );
  }
}
