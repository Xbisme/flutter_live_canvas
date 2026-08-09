package com.livecanvas.livecanvas

import android.content.Context
import android.util.Log
import java.io.File

/**
 * The native side's own tiny store for the live wallpaper's video path.
 *
 * Deliberately separate from the `shared_preferences` plugin's storage: the
 * wallpaper service runs after a reboot with no Flutter engine alive, so it
 * must be able to read this on its own, and depending on a plugin's internal
 * storage format is a silent-breakage waiting for the next version bump.
 *
 * Plain files rather than [android.content.SharedPreferences]: the writer is
 * the Flutter process and the reader is `:wallpaper` (see the manifest), and
 * `MODE_PRIVATE` preferences are cached per process — the reader would keep
 * serving whatever it loaded first and play the previous video forever.
 * `MODE_MULTI_PROCESS` is deprecated and was never reliable.
 *
 * Two paths, not one:
 *  - [pendingVideoPath] is what the system PREVIEW should play. It has to be
 *    on disk before the picker opens, because the preview engine reads it
 *    while the user is still deciding.
 *  - [activeVideoPath] is what the home screen plays, and only [commitPending]
 *    (i.e. `RESULT_OK`) promotes one to the other. Writing a single path up
 *    front would swap the user's real wallpaper the moment they *previewed*
 *    another one and backed out.
 */
object WallpaperPrefs {
    private const val ACTIVE = "livecanvas_active_wallpaper"
    private const val PENDING = "livecanvas_pending_wallpaper"
    private const val TAG = "LiveCanvasWallpaper"

    /** What the home-screen wallpaper plays; survives reboots. */
    fun activeVideoPath(context: Context): String? = read(context, ACTIVE)

    /**
     * What a preview engine should play: the candidate if the picker is open,
     * otherwise the wallpaper already in use (the system picker can also be
     * opened from Settings, with no candidate involved).
     */
    fun previewVideoPath(context: Context): String? =
        read(context, PENDING) ?: read(context, ACTIVE)

    /** Records the candidate, right before the system picker is launched. */
    fun setPendingVideoPath(context: Context, path: String) {
        write(context, PENDING, path)
    }

    /** `RESULT_OK`: the candidate becomes the wallpaper. */
    fun commitPending(context: Context) {
        val pending = File(context.filesDir, PENDING)
        if (!pending.exists()) return
        val active = File(context.filesDir, ACTIVE)
        try {
            active.delete()
            if (!pending.renameTo(active)) {
                // Different-filesystem or ROM quirk: copy, then drop the source.
                active.writeText(pending.readText())
                pending.delete()
            }
        } catch (e: Exception) {
            Log.e(TAG, "could not commit the pending wallpaper path", e)
        }
    }

    /** The user backed out of the preview: the candidate is forgotten. */
    fun clearPending(context: Context) {
        try {
            File(context.filesDir, PENDING).delete()
        } catch (e: Exception) {
            Log.w(TAG, "could not clear the pending wallpaper path", e)
        }
    }

    private fun read(context: Context, name: String): String? = try {
        val file = File(context.filesDir, name)
        // Read every time: this process is not the one that writes.
        if (!file.exists()) null else file.readText().trim().ifEmpty { null }
    } catch (e: Exception) {
        Log.w(TAG, "could not read $name", e)
        null
    }

    /**
     * Written to a temp file and renamed, so a reader in the other process
     * never sees a half-written path: the rename is atomic, the write is not.
     */
    private fun write(context: Context, name: String, value: String) {
        val target = File(context.filesDir, name)
        val temp = File(context.filesDir, "$name.tmp")
        try {
            temp.writeText(value)
            target.delete()
            if (!temp.renameTo(target)) throw java.io.IOException("rename failed")
        } catch (e: Exception) {
            Log.e(TAG, "could not persist $name", e)
            temp.delete()
        }
    }
}
