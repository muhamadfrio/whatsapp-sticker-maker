import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'module/sticker_maker/binding/sticker_maker_binding.dart';
import 'module/sticker_maker/screen/sticker_maker_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: StickerMakerBinding(),
      home: const StickerMakerScreen(),
    );
  }
}
