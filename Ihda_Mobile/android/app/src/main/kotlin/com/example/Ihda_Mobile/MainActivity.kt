package uz.ihda.mobile

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Set API Key and initialize MapKit
        MapKitFactory.setApiKey("7f9b9650-fcf6-4194-8005-1b2c65deba21")
        MapKitFactory.initialize(this)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    }
}
