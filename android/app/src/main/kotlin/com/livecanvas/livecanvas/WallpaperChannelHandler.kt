package com.livecanvas.livecanvas

import android.app.Activity
import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Android half of `com.livecanvas/wallpaper`.
 *
 * Error codes here are the contract with the Dart side, which is the only place
 * that turns them into an AppFailure (see contracts/method-channel.md).
 */
class WallpaperChannelHandler(
    private val activity: Activity,
) : MethodChannel.MethodCallHandler {

    private var pendingResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_IS_SUPPORTED -> result.success(isLiveWallpaperSupported())
            METHOD_SET_LIVE_WALLPAPER -> setLiveWallpaper(call, result)
            METHOD_SAVE_TO_PHOTOS, METHOD_OPEN_SHORTCUTS ->
                result.error(ERROR_UNSUPPORTED, "iOS only", null)
            else -> result.notImplemented()
        }
    }

    /**
     * Capability check, not a platform check: some ROMs ship without a
     * live-wallpaper picker, and the Dart side surfaces that as "device not
     * supported" rather than silently doing nothing.
     */
    private fun isLiveWallpaperSupported(): Boolean =
        changeLiveWallpaperIntent().resolveActivity(activity.packageManager) != null

    private fun setLiveWallpaper(call: MethodCall, result: MethodChannel.Result) {
        val filePath = call.argument<String>("filePath")
        if (filePath.isNullOrEmpty() || !File(filePath).exists()) {
            result.error(ERROR_FILE_MISSING, "video file not found", null)
            return
        }
        if (!isLiveWallpaperSupported()) {
            result.error(ERROR_UNSUPPORTED, "no live wallpaper picker", null)
            return
        }
        if (pendingResult != null) {
            result.error(ERROR_SET_FAILED, "a preview is already open", null)
            return
        }

        // Persist BEFORE launching the picker — the preview engine reads this
        // while the user is still deciding. It stays *pending* until they
        // confirm, so backing out leaves the current wallpaper alone.
        WallpaperPrefs.setPendingVideoPath(activity, filePath)

        return try {
            pendingResult = result
            activity.startActivityForResult(
                changeLiveWallpaperIntent(),
                REQUEST_SET_LIVE_WALLPAPER,
            )
        } catch (e: Exception) {
            Log.e(TAG, "could not open the live wallpaper picker", e)
            pendingResult = null
            result.error(ERROR_SET_FAILED, "could not open the picker", null)
        }
    }

    /**
     * Returns true when it consumed the result.
     *
     * `applied = false` (the user backed out of the system preview) is a normal
     * outcome, not an error — the Dart side keeps the downloaded file so a
     * retry costs no second download.
     */
    fun onActivityResult(requestCode: Int, resultCode: Int): Boolean {
        if (requestCode != REQUEST_SET_LIVE_WALLPAPER) return false
        val result = pendingResult ?: return false
        pendingResult = null

        val applied = resultCode == Activity.RESULT_OK
        if (applied) {
            WallpaperPrefs.commitPending(activity)
            // The engine is already bound and will NOT be recreated — the
            // component did not change — so it has to be told to re-read.
            activity.sendBroadcast(
                Intent(LiveCanvasWallpaperService.ACTION_RELOAD)
                    .setPackage(activity.packageName),
            )
        } else {
            WallpaperPrefs.clearPending(activity)
        }

        result.success(mapOf("applied" to applied))
        return true
    }

    /**
     * The component is built from the runtime context, never from a hardcoded
     * package string: the `development` flavor appends `.dev` to the
     * applicationId, so a literal would work in release and fail silently in
     * dev builds.
     */
    private fun changeLiveWallpaperIntent(): Intent =
        Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).putExtra(
            WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
            ComponentName(activity, LiveCanvasWallpaperService::class.java),
        )

    companion object {
        const val CHANNEL = "com.livecanvas/wallpaper"

        private const val METHOD_SET_LIVE_WALLPAPER = "setLiveWallpaper"
        private const val METHOD_SAVE_TO_PHOTOS = "saveVideoToPhotos"
        private const val METHOD_OPEN_SHORTCUTS = "openShortcuts"
        private const val METHOD_IS_SUPPORTED = "isLiveWallpaperSupported"

        private const val ERROR_UNSUPPORTED = "UNSUPPORTED"
        private const val ERROR_FILE_MISSING = "FILE_MISSING"
        private const val ERROR_SET_FAILED = "SET_FAILED"

        private const val REQUEST_SET_LIVE_WALLPAPER = 8051
        private const val TAG = "LiveCanvasWallpaper"
    }
}
