package com.rio.whatsappstickermaker

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.rio.whatsappstickermaker/whatsapp"
    private var pendingResult: MethodChannel.Result? = null

    companion object {
        private const val ADD_PACK_REQUEST = 200
        private const val TAG = "MainActivity"
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: Exception) {
            false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getFilesDir" -> {
                    result.success(context.filesDir.absolutePath)
                }
                "addStickerPack" -> {
                    val identifier = call.argument<String>("identifier") ?: ""
                    val name = call.argument<String>("name") ?: ""
                    pendingResult = result

                    try {
                        val targetPackage = if (isPackageInstalled("com.whatsapp")) {
                            "com.whatsapp"
                        } else if (isPackageInstalled("com.whatsapp.w4b")) {
                            "com.whatsapp.w4b"
                        } else {
                            null
                        }

                        val intent = Intent().apply {
                            action = "com.whatsapp.intent.action.ENABLE_STICKER_PACK"
                            if (targetPackage != null) {
                                setPackage(targetPackage)
                            }
                            putExtra("sticker_pack_id", identifier)
                            putExtra("sticker_pack_authority", "${applicationContext.packageName}.stickercontentprovider")
                            putExtra("sticker_pack_name", name)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }

                        startActivityForResult(intent, ADD_PACK_REQUEST)
                    } catch (e: ActivityNotFoundException) {
                        pendingResult = null
                        result.error("WHATSAPP_NOT_FOUND", "Aplikasi WhatsApp tidak ditemukan pada perangkat Anda.", null)
                    } catch (e: Exception) {
                        pendingResult = null
                        result.error("WHATSAPP_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ADD_PACK_REQUEST) {
            val result = pendingResult
            pendingResult = null
            if (result != null) {
                if (resultCode == Activity.RESULT_OK) {
                    result.success(true)
                } else {
                    val error = data?.getStringExtra("validation_error")
                    val extrasLog = data?.extras?.keySet()?.joinToString(", ") { key -> "$key=${data.extras?.get(key)}" } ?: "no extras"
                    Log.e(TAG, "WhatsApp rejected: resultCode=$resultCode, validation_error=$error, extras=[$extrasLog]")
                    result.error("WHATSAPP_REJECTED", error ?: "Gagal menambahkan stiker ke WhatsApp (validation_error=$error).", null)
                }
            }
        }
    }
}
