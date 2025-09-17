# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/koojh74/Library/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:


-keepattributes Signature, Exceptions, *Annotation*, SourceFile, LineNumberTable, EnclosingMethod

# Flutter 관련 규칙
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# 네이티브 플러그인 보호
-keep class com.loplat.placeengine.** { *; }

# 민감한 클래스 보호
-keep class com.example.diary_ai.DataManager { *; }
-keep class com.example.diary_ai.MainApplication { *; }

# R8 compatibility for GSON
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

-dontnote retrofit2.Platform
-dontwarn okio.**
-dontwarn retrofit2.Platform$Java8
-dontwarn okhttp3.**
-dontwarn javax.annotation.**
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}
-dontwarn okhttp3.internal.platform.*
-dontwarn org.conscrypt.*
ㅁ
# Google Play Core 라이브러리 관련 경고 억제
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
