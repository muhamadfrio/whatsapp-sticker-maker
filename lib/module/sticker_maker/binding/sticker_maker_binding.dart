import 'package:get/get.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/sticker_maker_controller.dart';

class StickerMakerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImagePicker>(() => ImagePicker());
    Get.lazyPut<SelfieSegmenter>(
      () => SelfieSegmenter(
        mode: SegmenterMode.single,
        enableRawSizeMask: true,
      ),
    );
    Get.lazyPut<StickerMakerController>(
      () => StickerMakerController(
        imagePicker: Get.find<ImagePicker>(),
        selfieSegmenter: Get.find<SelfieSegmenter>(),
      ),
    );
  }
}
