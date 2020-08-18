package com.dexter.socialshare

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Uri
import androidx.annotation.NonNull
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.net.URL
import java.net.URLEncoder

/** SocialSharePlugin */
public class SocialSharePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "social_share")
    channel.setMethodCallHandler(this)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {

    private var context: Activity? = null
    private var applicationContext: Context? = null

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      context = registrar.activity()
      applicationContext = registrar.context().applicationContext
      val channel = MethodChannel(registrar.messenger(), "social_share")
      channel.setMethodCallHandler(SocialSharePlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (isNetworkConnected()) {
      when (call.method) {
          "shareWhatsApp" -> {
            if (isAppInstalled("com.whatsapp")) {
              val data = Gson().fromJson(call.arguments.toString(), PostShare::class.java)
              when (data.type) {
                "text" -> {
                  val url : String?
                  url = if(data.phoneNumber != null) {
                    "https://api.whatsapp.com/send?phone=" + data.phoneNumber + "&text=" + URLEncoder.encode(data.message, "UTF-8")
                  } else {
                    "https://api.whatsapp.com/send?text=" + URLEncoder.encode(data.message, "UTF-8")
                  }
                  val intent = Intent()
                  intent.action = Intent.ACTION_VIEW
                  intent.data = Uri.parse(url)
                  intent.setPackage("com.whatsapp")
                  context!!.startActivity(intent)
                  result.success("Success")
                }
                else -> result.success("Type Not Implemented")
              }
            } else {
              result.success("App not installed")
            }
          }
        "shareTwitter" -> {
          if (isAppInstalled("com.twitter.android")) {
            val data = Gson().fromJson(call.arguments.toString(), PostShare::class.java)
            when (data.type) {
              "text" -> {
                val intent = Intent()
                intent.action = Intent.ACTION_SEND
                intent.putExtra(Intent.EXTRA_TEXT, data.message)
                intent.type = "text/plain"
                intent.setPackage("com.twitter.android")
                context!!.startActivity(intent)
                result.success("Success")
              }
              else -> result.success("Type Not Implemented")
            }
          } else {
            result.success("App not installed")
          }
        }
        "shareFacebook" -> {
          if (isAppInstalled("com.facebook.katana")) {
            val data = Gson().fromJson(call.arguments.toString(), PostShare::class.java)
            when (data.type) {
              "text" -> {
                try {
                  URL(data.message).toURI()
                  val intent = Intent()
                  intent.action = Intent.ACTION_SEND
                  intent.type = "text/plain"
                  intent.putExtra(Intent.EXTRA_TEXT, data.message)
                  intent.setPackage("com.facebook.katana")
                  context!!.startActivity(intent)
                  result.success("Success")
                } // If there was an Exception
                catch (e: Exception) {
                  result.success("Facebook allow only URL text")
                }
              }
              else -> result.success("Type Not Implemented")
            }
          } else {
            result.success("App not installed")
          }
        }
          else -> result.notImplemented()
      }
    } else {
      result.success("You are not connected to the Internet")
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun isAppInstalled(uri: String): Boolean {
    val pm = context!!.packageManager
    return try {
      pm.getPackageInfo(uri, PackageManager.GET_ACTIVITIES)
      true
    } catch (e: PackageManager.NameNotFoundException) {
      false
    }
  }

  private fun isNetworkConnected(): Boolean {
    val cm = context!!.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    return cm.activeNetworkInfo != null && cm.activeNetworkInfo.isConnected
  }

  override fun onDetachedFromActivity() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    context = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }
}
