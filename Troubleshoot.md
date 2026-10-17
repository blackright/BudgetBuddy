You are a friendly, expert coding coach. Your job is to look at the code error I give you, figure out exactly why it broke, and explain it to me using very simple language—like you are talking to a beginner or a child. 

CRITICAL RULE: You must STOP and wait for my explicit approval after you show me your plan. Do not change any files or run any code commands until I say "Approved" or "Proceed".

Please format your response exactly like this:

### 🔍 1. What Happened? (The Error)
* **The Oopsie:** Explain what broke in super simple, plain English. Use a fun everyday analogy (like a broken toy or a mixed-up recipe) if it helps!
* **Why It Happened:** Explain the root technical cause using easy words. No confusing jargon. 

### 🛠️ 2. The Fix-It Plan
* **The Smartest Fix:** How do real-world experts fix this perfectly? Explain it simply.
* **Other Ideas I Tossed Out:** Briefly mention one quick fix you ignored, and tell me in 1 simple sentence why it wasn't good enough.

### 📋 3. Step-by-Step To-Do List
Give me a clear, simple list of exactly what needs to change:
* Which files we need to open.
* The basic changes we need to make to the code.
* How we will test it afterwards to make sure it works.

### 🛑 STOP! WALKING GATE AHEAD
I am stopping here. Please read over my explanation and the plan. If you like it and want me to fix it, just reply with the word "Approved" and I will start typing up the code for you!
--------------------------------------------------
[CONTEXT & CODE ERRORS START]
{{
    
PS C:\dev\MobileDev\BudgetBuddy> flutter run
Launching lib\main.dart on SM G965F in debug mode...
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by net.rubygrapefruit.platform.internal.NativeLibraryLoader in an unnamed module (file:/C:/Users/Admin/.gradle/wrapper/dists/gradle-9.3.1-all/9ot9r568e8zfvvd4mn8rbu1j0/gradle-9.3.1/lib/native-platform-0.22-milestone-29.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled

WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): device_calendar, nsd_android
Future versions of Flutter will fail to build if your app uses plugins that apply KGP.

Please check the changelogs of these plugins and upgrade to a version that supports Built-in Kotlin.
If no such version exists, report the issue to the plugin. If necessary, here is a guide on filing
an issue against a plugin: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers#report-incompatible-kotlin-gradle-plugin-usage-to-plugin-authors

If you are a plugin author, please migrate your plugin to Built-in Kotlin using this guide: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors
Running Gradle task 'assembleDebug'...                             25.7s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...          61.1s
I/FlutterActivityAndFragmentDelegate( 5467): If you are attempting to set --enable-dart-profiling via Intent extras to launch a Flutter component outside of using the Flutter CLI, note that support for setting engine flags on Android via Intent will soon be dropped; see https://github.com/flutter/flutter/issues/180686 for more information on this breaking change. To migrate, set --enable-dart-profiling or any other flags specified via Intent extras on the command line instead or see https://github.com/flutter/flutter/blob/main/docs/engine/Flutter-Android-Engine-Flags.md for alternative methods.
D/FlutterJNI( 5467): Beginning load of flutter...
D/FlutterJNI( 5467): flutter (null) was loaded normally!
I/flutter ( 5467): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
D/FlutterRenderer( 5467): Width is zero. 0,0
Syncing files to device SM G965F...                                213ms

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on SM G965F is available at: http://127.0.0.1:56060/NKhSROY4R1k=/
The Flutter DevTools debugger and profiler on SM G965F is available at:
http://127.0.0.1:56060/NKhSROY4R1k=/devtools/?uri=ws://127.0.0.1:56060/NKhSROY4R1k=/ws
I/flutter ( 5467): ╔══════════════════════════════════════════════════════╗
I/flutter ( 5467): ║                 ISAR CONNECT STARTED                 ║
I/flutter ( 5467): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5467): ║         Open the link to connect to the Isar         ║
I/flutter ( 5467): ║        Inspector while this build is running.        ║
I/flutter ( 5467): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5467): ║ https://inspect.isar.dev/3.1.0+1/#/56060/NKhSROY4R1k ║
I/flutter ( 5467): ╚══════════════════════════════════════════════════════╝
I/Choreographer( 5467): Skipped 74 frames!  The application may be doing too much work on its main thread.
I/SurfaceView( 5467): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{9c88959 V.E...... ......I. 0,0-0,0} of ViewRootImpl@e9d1746[MainActivity]
D/FlutterRenderer( 5467): Width is zero. 0,0
D/FlutterRenderer( 5467): Width is zero. 0,0
I/ViewRootImpl@e9d1746[MainActivity]( 5467): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=8 res=0x7 s={true 506906042368} ch=true
D/FlutterJNI( 5467): Sending viewport metrics to the engine.
I/mali_winsys( 5467): new_window_surface() [1440x2960] return: 0x3000
I/SurfaceView( 5467): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{9c88959 V.E...... ......ID 0,0-1440,2792}
I/mali_winsys( 5467): new_window_surface() [1440x2792] return: 0x3000
I/SurfaceView( 5467): surfaceChanged (1440,2792) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{9c88959 V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 5467): eglDestroySurface() in
I/mali_winsys( 5467): delete_surface() [1440x2792] return
I/mali_egl( 5467): eglDestroySurface() out
W/libEGL  ( 5467): EGLNativeWindowType 0x760e289010 disconnect failed
I/mali_winsys( 5467): new_window_surface() [1440x2792] return: 0x3000
I/Choreographer( 5467): Skipped 84 frames!  The application may be doing too much work on its main thread.
I/ViewRootImpl@e9d1746[MainActivity]( 5467): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=5 res=0x3 s={true 506906042368} ch=false
I/SurfaceView( 5467): surfaceDestroyed callback.size 1 #3 io.flutter.embedding.android.FlutterSurfaceView{9c88959 G.E...... ......ID 0,0-1440,2792}
I/mali_egl( 5467): eglDestroySurface() in
I/mali_winsys( 5467): delete_surface() [1440x2792] return
I/mali_egl( 5467): eglDestroySurface() out
W/libEGL  ( 5467): EGLNativeWindowType 0x760e289010 disconnect failed
I/SurfaceView( 5467): remove() io.flutter.embedding.android.FlutterSurfaceView{9c88959 G.E...... ......ID 0,0-1440,2792} Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@9c88959@0)/@0xa117ac9
I/SurfaceView( 5467): onWindowVisibilityChanged(8) false io.flutter.embedding.android.FlutterSurfaceView{9c88959 G.E...... ......ID 0,0-1440,2792} of ViewRootImpl@e9d1746[MainActivity]
I/mali_egl( 5467): eglDestroySurface() in
I/mali_egl( 5467): eglDestroySurface() out
I/FlutterActivityAndFragmentDelegate( 5467): If you are attempting to set --enable-dart-profiling via Intent extras to launch a Flutter component outside of using the Flutter CLI, note that support for setting engine flags on Android via Intent will soon be dropped; see https://github.com/flutter/flutter/issues/180686 for more information on this breaking change. To migrate, set --enable-dart-profiling or any other flags specified via Intent extras on the command line instead or see https://github.com/flutter/flutter/blob/main/docs/engine/Flutter-Android-Engine-Flags.md for alternative methods.
I/flutter ( 5467): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
I/mali_egl( 5467): eglDestroySurface() in
I/mali_egl( 5467): eglDestroySurface() out
D/PhoneWindow( 5467): forceLight changed to true [] from com.android.internal.policy.PhoneWindow.updateForceLightNavigationBar:4274 com.android.internal.policy.DecorView.updateColorViews:1547 com.android.internal.policy.PhoneWindow.dispatchWindowAttributesChanged:3252 android.view.Window.setFlags:1153 com.android.internal.policy.PhoneWindow.generateLayout:2474
I/MultiWindowDecorSupport( 5467): [INFO] isPopOver = false
I/MultiWindowDecorSupport( 5467): updateCaptionType >> DecorView@850c705[], isFloating: false, isApplication: true, hasWindowDecorCaption: false, hasWindowControllerCallback: true
D/MultiWindowDecorSupport( 5467): setCaptionType = 0, DecorView = DecorView@850c705[]
D/AccessibilityBridge( 5467): Setting not found: accessibility_display_inversion_enabled, using default: 0
D/FlutterRenderer( 5467): Width is zero. 0,0
I/SurfaceView( 5467): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......I. 0,0-0,0} of ViewRootImpl@e9d1746[MainActivity]
I/ViewRootImpl@e9d1746[MainActivity]( 5467): stopped(false) old=false
I/flutter ( 5467): ╔══════════════════════════════════════════════════════╗
I/flutter ( 5467): ║                 ISAR CONNECT STARTED                 ║
I/flutter ( 5467): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5467): ║         Open the link to connect to the Isar         ║
I/flutter ( 5467): ║        Inspector while this build is running.        ║
I/flutter ( 5467): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5467): ║ https://inspect.isar.dev/3.1.0+1/#/56060/NKhSROY4R1k ║
I/flutter ( 5467): ╚══════════════════════════════════════════════════════╝
I/ViewRootImpl@e9d1746[MainActivity]( 5467): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 5467): prepareNavigationBarInfo() DecorView@850c705[]
D/InputMethodManager( 5467): getNavigationBarColor() -855310
W/FlutterFragment( 5467): FlutterFragment 13809347 onWindowFocusChanged called after release.
D/InputMethodManager( 5467): prepareNavigationBarInfo() DecorView@850c705[]
D/InputMethodManager( 5467): getNavigationBarColor() -855310
V/InputMethodManager( 5467): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -855310 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 5467): startInputInner - Id : 0
I/InputMethodManager( 5467): startInputInner - mService.startInputOrWindowGainedFocus
I/Choreographer( 5467): Skipped 124 frames!  The application may be doing too much work on its main thread.
D/FlutterRenderer( 5467): Width is zero. 0,0
I/ViewRootImpl@e9d1746[MainActivity]( 5467): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=6 res=0x3 s={true 506906042368} ch=false
D/FlutterJNI( 5467): Sending viewport metrics to the engine.
I/SurfaceView( 5467): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792}
I/mali_winsys( 5467): new_window_surface() [1440x2792] return: 0x3000
I/SurfaceView( 5467): surfaceChanged (1440,2792) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 5467): eglDestroySurface() in
I/mali_winsys( 5467): delete_surface() [1440x2792] return
I/mali_egl( 5467): eglDestroySurface() out
W/libEGL  ( 5467): EGLNativeWindowType 0x7612226010 disconnect failed
I/mali_winsys( 5467): new_window_surface() [1440x2792] return: 0x3000
I/ViewRootImpl@e9d1746[MainActivity]( 5467): MSG_RESIZED_REPORT: frame=(0,0,1440,2960) ci=(0,84,0,168) vi=(0,84,0,168) or=1
I/Choreographer( 5467): Skipped 128 frames!  The application may be doing too much work on its main thread.
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467): Failed to handle method call
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467): java.lang.NullPointerException: Attempt to invoke virtual method 'android.content.res.Resources android.content.Context.getResources()' on a null object reference
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin.isValidDrawableResource(FlutterLocalNotificationsPlugin.java:1459)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin.initialize(FlutterLocalNotificationsPlugin.java:1886)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin.onMethodCall(FlutterLocalNotificationsPlugin.java:1628)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at io.flutter.plugin.common.MethodChannel$IncomingMethodCallHandler.onMessage(MethodChannel.java:267)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at io.flutter.embedding.engine.dart.DartMessenger.invokeHandler(DartMessenger.java:286)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at io.flutter.embedding.engine.dart.DartMessenger.lambda$dispatchMessageToQueue$0$io-flutter-embedding-engine-dart-DartMessenger(DartMessenger.java:313)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at io.flutter.embedding.engine.dart.DartMessenger$$ExternalSyntheticLambda0.run(D8$$SyntheticClass:0)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at android.os.Handler.handleCallback(Handler.java:883)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at android.os.Handler.dispatchMessage(Handler.java:100)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at android.os.Looper.loop(Looper.java:237)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at android.app.ActivityThread.main(ActivityThread.java:8167)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at java.lang.reflect.Method.invoke(Native Method)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:496)
E/MethodChannel#dexterous.com/flutter/local_notifications( 5467):       at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1100)
W/FlutterJNI( 5467): Tried to send a platform message response, but FlutterJNI was detached from native C++. Could not send. Response ID: 5
D/InputMethodManager( 5467): prepareNavigationBarInfo() DecorView@850c705[]
D/InputMethodManager( 5467): getNavigationBarColor() -855310
V/InputMethodManager( 5467): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -855310 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 5467): startInputInner - Id : 0
D/FlutterJNI( 5467): Sending viewport metrics to the engine.
W/Gralloc3( 5467): mapper 3.x is not supported
I/gralloc ( 5467): Arm Module v1.0
I/Choreographer( 5467): Skipped 97 frames!  The application may be doing too much work on its main thread.
D/PhoneWindow( 5467): forceLight changed to false [] from com.android.internal.policy.PhoneWindow.updateForceLightNavigationBar:4280 com.android.internal.policy.PhoneWindow.setNavigationBarColor:4102 io.flutter.plugin.platform.PlatformPlugin.setSystemChromeSystemUIOverlayStyle:578 io.flutter.plugin.platform.PlatformPlugin.access$700:37 io.flutter.plugin.platform.PlatformPlugin$1.setSystemUiOverlayStyle:125
D/ProfileInstaller( 5467): Installing profile for com.example.budget_buddy
I/Choreographer( 5467): Skipped 144 frames!  The application may be doing too much work on its main thread.
I/ViewRootImpl@e9d1746[MainActivity]( 5467): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=9 res=0x3 s={true 506906042368} ch=false
D/FlutterJNI( 5467): Sending viewport metrics to the engine.
I/Choreographer( 5467): Skipped 31 frames!  The application may be doing too much work on its main thread.
I/ViewRootImpl@e9d1746[MainActivity]( 5467): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=4 res=0x3 s={true 506906042368} ch=false
D/FlutterJNI( 5467): Sending viewport metrics to the engine.
I/ViewRootImpl@e9d1746[MainActivity]( 5467): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager( 5467): prepareNavigationBarInfo() DecorView@850c705[]
D/InputMethodManager( 5467): getNavigationBarColor() -16777216
W/FlutterFragment( 5467): FlutterFragment 13809347 onWindowFocusChanged called after release.
D/InputTransport( 5467): Input channel destroyed: 'ClientS', fd=98
I/AssistStructure( 5467): Flattened final assist data: 840 bytes, containing 1 windows, 9 views
I/SurfaceView( 5467): onWindowVisibilityChanged(8) false io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792} of ViewRootImpl@e9d1746[MainActivity]
I/SurfaceView( 5467): surfaceDestroyed callback.size 1 #2 io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 5467): eglDestroySurface() in
I/mali_winsys( 5467): delete_surface() [1440x2792] return
I/mali_egl( 5467): eglDestroySurface() out
W/libEGL  ( 5467): EGLNativeWindowType 0x7612226010 disconnect failed
I/SurfaceView( 5467): remove() io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792} Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@517e08e@0)/@0x6cf496d
I/mali_egl( 5467): eglDestroySurface() in
I/mali_winsys( 5467): delete_surface() [1440x2960] return
I/mali_egl( 5467): eglDestroySurface() out
W/libEGL  ( 5467): EGLNativeWindowType 0x76121e2690 disconnect failed
I/ViewRootImpl@e9d1746[MainActivity]( 5467): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)8 dur=47 res=0x5 s={false 0} ch=true
I/ViewRootImpl@e9d1746[MainActivity]( 5467): stopped(true) old=false
I/SurfaceView( 5467): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792} of ViewRootImpl@e9d1746[MainActivity]
I/SurfaceView( 5467): onWindowVisibilityChanged(4) false io.flutter.embedding.android.FlutterSurfaceView{517e08e G.E...... ......ID 0,0-1440,2792} of ViewRootImpl@e9d1746[MainActivity]
I/ViewRootImpl@e9d1746[MainActivity]( 5467): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)4 dur=17 res=0x1 s={false 0} ch=false
I/ViewRootImpl@e9d1746[MainActivity]( 5467): stopped(false) old=true
I/SurfaceView( 5467): windowStopped(false) false io.flutter.embedding.android.FlutterSurfaceView{517e08e G.E...... ......ID 0,0-1440,2792} of ViewRootImpl@e9d1746[MainActivity]
I/ViewRootImpl@e9d1746[MainActivity]( 5467): stopped(false) old=false
I/SurfaceView( 5467): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792} of ViewRootImpl@e9d1746[MainActivity]
I/ViewRootImpl@e9d1746[MainActivity]( 5467): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=8 res=0x7 s={true 507112431616} ch=true
I/SurfaceView( 5467): surfaceCreated 1 #5 io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792}
I/mali_winsys( 5467): new_window_surface() [1440x2960] return: 0x3000
I/mali_winsys( 5467): new_window_surface() [1440x2792] return: 0x3000
I/SurfaceView( 5467): surfaceChanged (1440,2792) 1 #5 io.flutter.embedding.android.FlutterSurfaceView{517e08e V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 5467): eglDestroySurface() in
I/mali_winsys( 5467): delete_surface() [1440x2792] return
I/mali_egl( 5467): eglDestroySurface() out
W/libEGL  ( 5467): EGLNativeWindowType 0x7605f72010 disconnect failed
I/mali_winsys( 5467): new_window_surface() [1440x2792] return: 0x3000
I/ViewRootImpl@e9d1746[MainActivity]( 5467): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 5467): prepareNavigationBarInfo() DecorView@850c705[]
D/InputMethodManager( 5467): getNavigationBarColor() -16777216
W/FlutterFragment( 5467): FlutterFragment 13809347 onWindowFocusChanged called after release.
D/InputMethodManager( 5467): prepareNavigationBarInfo() DecorView@850c705[]
D/InputMethodManager( 5467): getNavigationBarColor() -16777216
V/InputMethodManager( 5467): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 5467): startInputInner - Id : 0
I/InputMethodManager( 5467): startInputInner - mService.startInputOrWindowGainedFocus

}}
[CONTEXT & CODE ERRORS END]
