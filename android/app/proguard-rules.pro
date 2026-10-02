############################################
# Flutter + Dart
############################################
# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-dontwarn io.flutter.**

############################################
# AndroidX / Jetpack (used by Flutter plugins)
############################################
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

############################################
# Kotlin coroutines (used by many plugins)
############################################
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

############################################
# ONNX Runtime (used by flutter_onnxruntime)
############################################
-keep class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**

############################################
# Miscellaneous
############################################
# Keep constructors
-keepclassmembers class * {
    public <init>(...);
}

# Keep enums
-keepclassmembers enum * {
    **[] $VALUES;
    public *;
}
