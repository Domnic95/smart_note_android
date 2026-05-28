# =====================================================================
# R8 / ProGuard rules for smart-note-app
#
# Generated to fix the "Missing classes detected while running R8"
# errors reported by ./gradlew :app:minifyReleaseWithR8. Every class
# the error log mentions is covered by a -dontwarn pattern below.
# =====================================================================

# ---- google_mlkit_text_recognition optional language packs ----------
# The plugin's TextRecognizer.initialize() defensively references the
# Chinese / Japanese / Korean / Devanagari TextRecognizerOptions
# classes, but we don't add their dependencies (we only ship the
# default Latin recognizer), so R8 can't resolve them. The code paths
# that touch these classes are unreachable at runtime, so -dontwarn is
# the correct fix.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**

# ---- OpenCV referenced by flutter_document_scanner -------------------
# build.gradle has configurations.all { exclude ... opencv } which
# strips the OpenCV libs at link time, so org.opencv.* is not on the
# classpath. Silence R8 for the now-unreachable references.
-dontwarn org.opencv.**

# ---- Defensive ML Kit keep rules -------------------------------------
# ML Kit and the Flutter wrappers reflect on these classes; keep them
# so minification doesn't accidentally strip something useful.
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }

# ---- Play Core deferred-components ----------------------------------
# Flutter embedding references Play Core's SplitCompat/SplitInstall
# APIs even when you don't use deferred components.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# ---- Kotlin metadata -------------------------------------------------
# Some plugins (and the OneSignal SDK) use kotlin-reflect / metadata.
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$Companion { *; }

# ---- Flutter plugin entry points ------------------------------------
# Plugins are wired up by name via GeneratedPluginRegistrant.
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# ---- JNI / native-method protection ---------------------------------
# Three layers of protection for plugins that bridge to C/C++ via JNI:
#
#   1. Any class that DECLARES a native method must keep its name AND
#      the method's name (JNI looks up symbols by Java_<Pkg>_<Class>_<method>).
#   2. Any class that CALLS System.loadLibrary() needs its static
#      initializer preserved so the .so is actually loaded at runtime.
#   3. Any class instantiated FROM C++ via JNIEnv->FindClass() needs
#      to keep its name. R8 can't see these reflective uses.
#
# Keep specific JNI-using plugins entirely so all three concerns are
# covered with one rule per plugin.

# flutter_pdfview — wraps native pdfium via JNI
-keep class io.legere.pdfviewerflutter.** { *; }
-keep class com.shockwave.** { *; }

# pdfx — wraps native pdfium via JNI (replacement for pdf_render_maintained,
# whose own native lib shipped with mismatched JNI symbol names).
-keep class io.scer.pdfx.** { *; }

# Generic safety net: any class anywhere with a native method keeps
# both its name and the method's name. This is what
# proguard-android-optimize.txt does too, but spelling it out here in
# case future plugin updates ever need it.
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}
