package com.livecanvas.livecanvas

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var wallpaperHandler: WallpaperChannelHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val handler = WallpaperChannelHandler(this)
        wallpaperHandler = handler
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WallpaperChannelHandler.CHANNEL,
        ).setMethodCallHandler(handler)
    }

    /**
     * The live-wallpaper picker is a separate activity, so its outcome comes
     * back here; forward it so the pending Dart call can complete.
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (wallpaperHandler?.onActivityResult(requestCode, resultCode) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }
}
