package com.livecanvas.livecanvas

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaPlayer
import android.os.Build
import android.service.wallpaper.WallpaperService
import android.util.Log
import android.view.SurfaceHolder
import java.io.File

/**
 * Plays the downloaded master video as the device's live wallpaper.
 *
 * The video path is read from a SharedPreferences file this native side owns
 * outright ([WallpaperPrefs]) — never from the `shared_preferences` plugin's
 * store. After a reboot the system recreates this service *without* starting a
 * Flutter engine, so there is nothing on the Dart side to ask; and reaching
 * into the plugin's storage would couple us to its internals (it already moved
 * from XML to DataStore once).
 */
class LiveCanvasWallpaperService : WallpaperService() {

    override fun onCreateEngine(): Engine = VideoEngine()

    private inner class VideoEngine : Engine() {
        private var player: MediaPlayer? = null

        /**
         * `player != null` only means "an instance exists" — between
         * `prepareAsync()` and the prepared callback it is still PREPARING, and
         * `start()`/`pause()` on it are an IllegalState (native error -38).
         * Every transport call goes through this flag.
         */
        private var prepared = false

        /** What [player] was built from, so a changed path can be detected. */
        private var playingPath: String? = null

        private var receiverRegistered = false

        /**
         * The explicit "the user just confirmed a new wallpaper" signal.
         *
         * Without it the reload would depend on this engine happening to
         * become visible *after* the app process commits the new path — a race
         * whose losing side is "you set a wallpaper and nothing changed".
         */
        private val reloadReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (isPreview) return
                if (activeVideoPath() == playingPath) return
                startPlayback(surfaceHolder)
            }
        }

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            val context = this@LiveCanvasWallpaperService
            val filter = IntentFilter(ACTION_RELOAD)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    context.registerReceiver(
                        reloadReceiver,
                        filter,
                        Context.RECEIVER_NOT_EXPORTED,
                    )
                } else {
                    context.registerReceiver(reloadReceiver, filter)
                }
                receiverRegistered = true
            } catch (e: Exception) {
                // The visibility check in onVisibilityChanged still covers it.
                Log.w(TAG, "could not register the reload receiver", e)
            }
        }

        override fun onDestroy() {
            if (receiverRegistered) {
                receiverRegistered = false
                try {
                    this@LiveCanvasWallpaperService.unregisterReceiver(reloadReceiver)
                } catch (e: Exception) {
                    Log.w(TAG, "could not unregister the reload receiver", e)
                }
            }
            releasePlayer()
            super.onDestroy()
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            startPlayback(holder)
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            releasePlayer()
            super.onSurfaceDestroyed(holder)
        }

        /**
         * Pause while the wallpaper is hidden (another app in front, screen
         * off). Decoding frames nobody can see is pure battery drain.
         */
        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)

            // Applying a second wallpaper does NOT recreate this engine: the
            // component is unchanged, so WallpaperManagerService logs
            // "Changing to the same component, ignoring" and nothing rebinds.
            // Becoming visible again is the only signal we get, so the stored
            // path is re-read here — otherwise the home screen keeps playing
            // whatever was set first, forever.
            if (visible && activeVideoPath() != playingPath) {
                startPlayback(surfaceHolder)
                return
            }

            val current = player ?: return
            // Still preparing: the prepared callback reads isVisible itself, so
            // dropping this event loses nothing.
            if (!prepared) return
            try {
                if (visible) current.start() else current.pause()
            } catch (e: IllegalStateException) {
                Log.w(TAG, "visibility change on a stale player", e)
            }
        }

        /**
         * Null when nothing was ever set, or the file was pruned away.
         *
         * A preview engine plays the candidate the picker was opened with; the
         * real wallpaper engine only ever plays what was actually confirmed.
         */
        private fun activeVideoPath(): String? {
            val context = this@LiveCanvasWallpaperService
            val path = if (isPreview) {
                WallpaperPrefs.previewVideoPath(context)
            } else {
                WallpaperPrefs.activeVideoPath(context)
            }
            return path?.takeIf { File(it).exists() }
        }

        private fun startPlayback(holder: SurfaceHolder) {
            val path = activeVideoPath()
            if (path == null) {
                // Nothing to play (first install, or the file was cleaned up).
                // Leaving the surface untouched is better than crashing the
                // system wallpaper host.
                Log.w(TAG, "no playable video for the live wallpaper")
                return
            }

            releasePlayer()
            try {
                // Deliberately NOT `MediaPlayer().apply { ... }`: inside `apply`
                // the implicit receiver is the MediaPlayer, so a `release()` in
                // the error listener would resolve to `MediaPlayer.release()`
                // and leave `player` pointing at a dead instance.
                val instance = MediaPlayer()
                player = instance
                playingPath = path
                instance.setSurface(holder.surface)
                instance.setDataSource(path)
                instance.isLooping = true          // FR-012: loops continuously
                instance.setVolume(0f, 0f)         // FR-012: silent
                instance.setOnPreparedListener {
                    prepared = true
                    if (isVisible) it.start()
                }
                instance.setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error what=$what extra=$extra")
                    releasePlayer()
                    true
                }
                instance.prepareAsync()
            } catch (e: Exception) {
                Log.e(TAG, "could not start the live wallpaper", e)
                releasePlayer()
            }
        }

        private fun releasePlayer() {
            prepared = false
            playingPath = null
            try {
                player?.release()
            } catch (e: Exception) {
                Log.w(TAG, "player release failed", e)
            }
            player = null
        }
    }

    companion object {
        /**
         * Sent by the app process once a new wallpaper is confirmed. Broadcast
         * because the engine lives in the `:wallpaper` process — there is no
         * shared memory to poke.
         */
        const val ACTION_RELOAD = "com.livecanvas.livecanvas.RELOAD_WALLPAPER"

        private const val TAG = "LiveCanvasWallpaper"
    }
}
