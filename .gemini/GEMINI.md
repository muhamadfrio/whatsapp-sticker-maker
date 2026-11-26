# GEMINI.md — Project Rules & Behavioral Guidelines

Panduan perilaku AI dan standar arsitektur wajib untuk proyek **com.rio.whatsappstickermaker**. Patuhi seluruh aturan di bawah ini sebelum membaca, merencanakan, atau menulis kode untuk aplikasi pembuat stiker WhatsApp ini.

---

## PART I: Behavioral Guidelines (Anti-Mistake Principles)

### 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.**
- Nyatakan asumsi secara eksplisit sebelum menulis kode. Terutama terkait manipulasi Canvas, pemrosesan gambar (WebP, 512x512, <100kb), dan konfigurasi native Android/iOS.
- Jika ada beberapa opsi implementasi (misal: hapus background via ML Kit vs Canvas Masking), paparkan pilihannya beserta *tradeoff*-nya—jangan memilih diam-diam.
- Jika ada pendekatan yang jauh lebih sederhana, sampaikan.

### 2. Simplicity First
**Minimum code that solves the problem. Nothing speculative.**
- Jangan menambahkan fitur, parameter, atau konfigurasi di luar yang diminta.
- Jangan membuat abstraksi (*mixin*, *base class*, *helper* baru) untuk kode yang hanya dipakai sekali.
- Jangan menulis *error handling* untuk skenario yang tidak mungkin terjadi.

### 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.**
- **Dilarang** mengubah, memformat ulang, atau "memperbaiki" kode di sekitar area perubahan yang tidak rusak.
- Ikuti gaya penulisan kode yang sudah ada di file tersebut.
- Hapus *import*, variabel, atau fungsi tidak terpakai **hanya** jika disebabkan oleh perubahanmu sendiri.
- Setiap baris yang berubah dalam *git diff* harus dapat ditelusuri langsung ke permintaan user.

### 4. Goal-Driven Execution
**Define success criteria. Loop until verified.**
- Untuk tugas multi-langkah (misal: integrasi intent ke WhatsApp), tulis rencana singkat sebelum eksekusi:
  ```text
  1. [Langkah] -> verify: [cara cek]
  2. [Langkah] -> verify: [cara cek]
  ```

---

## PART II: Flutter Architecture & Coding Standards (GetX)

Gunakan standar arsitektur berbasis GetX berikut untuk seluruh struktur kode di dalam `lib/`.

### 1. Struktur Folder Modular
Seluruh fitur harus modular. Jangan mencampur UI dan logic.
- `lib/core/`: Fondasi sistem (contoh: `assets/app_assets.dart`, `style/app_color.dart`, config native).
- `lib/common/`: Komponen lintas modul yang bisa dipakai ulang (contoh: loading widget, custom appbar).
- `lib/module/<nama_modul>/`: Terbagi menjadi `data/` (`model/`, `network/`, `repo/`) dan sub-fitur UI (`binding/`, `controller/`, `screen/`, `widget/`).

### 2. Dependency Injection (Wajib Constructor Injection via Bindings)
- **DILARANG KERAS** melakukan inisialisasi instance secara langsung di dalam class (misal: `final repo = StickerRepo()`).
- **Controller & Service:** Wajib menerima dependensi melalui *constructor*.
  ```dart
  class StickerMakerController extends GetxController {
    final ImageProcessingService imageService;
    StickerMakerController({required this.imageService});
  }
  ```
- **Bindings:** Daftarkan dan hubungkan semua dependensi secara *lazy* di file `*_binding.dart`:
  ```dart
  class StickerMakerBinding extends Bindings {
    @override
    void dependencies() {
      Get.lazyPut<ImageProcessingService>(() => ImageProcessingService());
      Get.lazyPut<StickerMakerController>(() => StickerMakerController(imageService: Get.find()));
    }
  }
  ```

### 3. Screen & View Standardization (Wajib `GetView<T>`)
- **DILARANG** membuat screen dengan `StatelessWidget` lalu memanggil `Get.find<Controller>()` di dalam `build()`.
- **WAJIB** menggunakan `GetView<T>` agar variabel `controller` langsung tersedia dari *parent class*.
  ```dart
  class StickerMakerScreen extends GetView<StickerMakerController> {
    const StickerMakerScreen({super.key});
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
         // Gunakan controller langsung
         body: Obx(() => ...), 
      );
    }
  }
  ```

### 4. State Resource & Loading Terpusat
- **Loading Indicator:** Gunakan State / Obx untuk mengatur visibilitas *loading indicator* saat memproses gambar (seperti *auto-remove background* atau ekspor ke WebP).
- **Hardcode Prevention:** **DILARANG** hardcode kode warna hex (`Color(0xFF...)`) atau path string aset jika sudah tersedia di *core styling* atau *core assets*. Selalu rujuk ke class terpusat.

### 5. Aturan Khusus Stiker WhatsApp
Semua *output* gambar untuk stiker **wajib**:
1. Berformat `.webp`.
2. Berdimensi tepat `512 x 512` piksel (gunakan *transparent padding* jika rasio asli tidak kotak).
3. Berukuran di bawah `100 KB`.
4. Memiliki *tray icon* terpisah berukuran `96 x 96` piksel.