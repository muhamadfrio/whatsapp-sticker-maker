package com.rio.whatsappstickermaker

import android.content.ContentProvider
import android.content.ContentValues
import android.content.UriMatcher
import android.content.res.AssetFileDescriptor
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.File

class StickerContentProvider : ContentProvider() {
    companion object {
        private const val TAG = "StickerProvider"
        private const val METADATA = 1
        private const val METADATA_CODE = 2
        private const val STICKERS = 3
        private const val STICKER_FILE = 4

        private lateinit var AUTHORITY: String
        private lateinit var uriMatcher: UriMatcher
    }

    private val stickerDir: File
        get() = File(context!!.filesDir, "sticker_packs")

    override fun onCreate(): Boolean {
        AUTHORITY = "${context!!.packageName}.stickercontentprovider"
        uriMatcher = UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(AUTHORITY, "metadata", METADATA)
            addURI(AUTHORITY, "metadata/*", METADATA_CODE)
            addURI(AUTHORITY, "stickers/*", STICKERS)
            addURI(AUTHORITY, "stickers_asset/*", STICKER_FILE)
            addURI(AUTHORITY, "stickers_asset/*/*", STICKER_FILE)
        }
        Log.i(TAG, "ContentProvider created with authority: $AUTHORITY")
        return true
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor? {
        val match = uriMatcher.match(uri)
        Log.i(TAG, "query received: $uri, match=$match")

        if (!stickerDir.exists()) {
            Log.e(TAG, "Sticker directory does not exist: ${stickerDir.absolutePath}")
            return null
        }

        return when (match) {
            METADATA -> getPackListCursor()
            METADATA_CODE -> {
                val packId = uri.lastPathSegment ?: return null
                getPackCursor(packId)
            }
            STICKERS -> {
                val packId = uri.lastPathSegment ?: return null
                getStickersCursor(packId)
            }
            else -> {
                Log.w(TAG, "Unknown URI: $uri (match=$match)")
                null
            }
        }
    }

    private fun getPackListCursor(): Cursor {
        val cursor = MatrixCursor(arrayOf(
            "sticker_pack_identifier",
            "sticker_pack_name",
            "sticker_pack_publisher",
            "sticker_pack_icon",
            "android_play_store_link",
            "ios_app_download_link",
            "sticker_pack_publisher_email",
            "sticker_pack_publisher_website",
            "sticker_pack_privacy_policy_website",
            "sticker_pack_license_agreement_website",
            "image_data_version",
            "whatsapp_will_not_cache_stickers",
            "animated_sticker_pack"
        ))

        stickerDir.listFiles()?.filter { it.isDirectory }?.forEach { packDir ->
            addPackRow(cursor, packDir)
        }

        Log.i(TAG, "getPackListCursor returning ${cursor.count} rows")
        return cursor
    }

    private fun getPackCursor(packId: String): Cursor {
        val cursor = MatrixCursor(arrayOf(
            "sticker_pack_identifier",
            "sticker_pack_name",
            "sticker_pack_publisher",
            "sticker_pack_icon",
            "android_play_store_link",
            "ios_app_download_link",
            "sticker_pack_publisher_email",
            "sticker_pack_publisher_website",
            "sticker_pack_privacy_policy_website",
            "sticker_pack_license_agreement_website",
            "image_data_version",
            "whatsapp_will_not_cache_stickers",
            "animated_sticker_pack"
        ))

        val packDir = File(stickerDir, packId)
        if (packDir.exists()) {
            addPackRow(cursor, packDir)
        } else {
            Log.e(TAG, "getPackCursor packDir missing: ${packDir.absolutePath}")
        }

        Log.i(TAG, "getPackCursor for $packId returning ${cursor.count} rows")
        return cursor
    }

    private fun addPackRow(cursor: MatrixCursor, packDir: File) {
        val configFile = File(packDir, "config.txt")
        if (!configFile.exists()) {
            Log.e(TAG, "config.txt missing in ${packDir.absolutePath}")
            return
        }

        val lines = configFile.readLines()
        val name = lines.getOrNull(0) ?: packDir.name
        val author = lines.getOrNull(1) ?: "Rio Sticker Maker"
        val isAnimated = lines.getOrNull(2) == "1"
        val version = lines.getOrNull(3) ?: "1"

        Log.i(TAG, "addPackRow: packId=${packDir.name}, name=$name, version=$version")

        cursor.addRow(arrayOf(
            packDir.name,                             // sticker_pack_identifier
            name,                                     // sticker_pack_name
            author,                                   // sticker_pack_publisher
            "tray.png",                               // sticker_pack_icon
            "",                                       // android_play_store_link
            "",                                       // ios_app_download_link
            "",                                       // sticker_pack_publisher_email
            "",                                       // sticker_pack_publisher_website
            "",                                       // sticker_pack_privacy_policy_website
            "",                                       // sticker_pack_license_agreement_website
            version,                                  // image_data_version
            "0",                                      // whatsapp_will_not_cache_stickers
            if (isAnimated) "1" else "0"              // animated_sticker_pack
        ))
    }

    private fun getStickersCursor(packId: String): Cursor {
        val cursor = MatrixCursor(arrayOf(
            "sticker_file_name",
            "sticker_emoji",
            "sticker_accessibility_text"
        ))

        val packDir = File(stickerDir, packId)
        if (!packDir.exists()) {
            Log.e(TAG, "Pack dir missing: ${packDir.absolutePath}")
            return cursor
        }

        val stickerFiles = packDir.listFiles()?.filter {
            it.name.endsWith(".webp") &&
            !it.name.startsWith("tray") &&
            it.name != "config.txt"
        }?.sortedBy { it.name }

        stickerFiles?.forEach { file ->
            Log.i(TAG, "Sticker file found: ${file.name}, size=${file.length()} bytes")
            cursor.addRow(arrayOf(file.name, "\uD83D\uDE00", ""))
        }

        Log.i(TAG, "getStickersCursor for $packId returning ${cursor.count} stickers")
        return cursor
    }

    private fun findStickerFile(uri: Uri): File? {
        val segments = uri.pathSegments
        Log.i(TAG, "findStickerFile uri: $uri, segments: $segments")
        if (segments.isEmpty() || segments[0] != "stickers_asset") return null

        if (segments.size >= 3) {
            val packId = segments[1]
            val fileName = segments[2]
            val file = File(stickerDir, "$packId/$fileName")
            if (file.exists()) return file
        } else if (segments.size == 2) {
            val fileName = segments[1]
            stickerDir.listFiles()?.filter { it.isDirectory }?.sortedByDescending { it.lastModified() }?.forEach { packDir ->
                val file = File(packDir, fileName)
                if (file.exists()) return file
            }
        }
        return null
    }

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor? {
        Log.i(TAG, "openFile called: $uri")
        val file = findStickerFile(uri)
        if (file != null && file.exists()) {
            file.setReadable(true, false)
            Log.i(TAG, "openFile success: ${file.absolutePath}, size=${file.length()} bytes")
            return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        } else {
            Log.e(TAG, "openFile error: File not found for $uri")
        }
        return super.openFile(uri, mode)
    }

    override fun openAssetFile(uri: Uri, mode: String): AssetFileDescriptor? {
        Log.i(TAG, "openAssetFile called: $uri")
        val file = findStickerFile(uri)
        if (file != null && file.exists()) {
            file.setReadable(true, false)
            val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            Log.i(TAG, "openAssetFile success: ${file.absolutePath}, size=${file.length()} bytes")
            return AssetFileDescriptor(pfd, 0, file.length())
        } else {
            Log.e(TAG, "openAssetFile error: File not found for $uri")
        }
        return super.openAssetFile(uri, mode)
    }

    override fun getType(uri: Uri): String {
        Log.i(TAG, "getType called: $uri")
        val segments = uri.pathSegments
        if (segments.isNotEmpty() && segments[0] == "stickers_asset") {
            val fileName = segments.last()
            if (fileName.endsWith(".png")) {
                return "image/png"
            }
            if (fileName.endsWith(".webp")) {
                return "image/webp"
            }
        }
        return when (uriMatcher.match(uri)) {
            METADATA, METADATA_CODE -> "vnd.android.cursor.dir/vnd.$AUTHORITY.metadata"
            STICKERS -> "vnd.android.cursor.dir/vnd.$AUTHORITY.stickers"
            else -> "application/octet-stream"
        }
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}
