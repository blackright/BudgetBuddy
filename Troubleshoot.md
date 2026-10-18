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
    
PHONE B - THIS IS THE PHONE THAT IS BEING ADDED TO THE SHARED SPACE OF PHONE A

PS C:\dev\MobileDev\BudgetBuddy> flutter run
Connected devices:
SM G965F (mobile) • 2291940c08037ece     • android-arm64  • Android 10 (API 29)
SM N950F (mobile) • 988a1b37395241584d30 • android-arm64  • Android 9 (API 28)
Windows (desktop) • windows              • windows-x64    • Microsoft Windows [Version
10.0.26300.9457]
Chrome (web)      • chrome               • web-javascript • Google Chrome 155.0.8059.39
Edge (web)        • edge                 • web-javascript • Microsoft Edge 155.0.4283.45
[1]: SM G965F (2291940c08037ece)
[2]: SM N950F (988a1b37395241584d30)
[3]: Windows (windows)
[4]: Chrome (chrome)
[5]: Edge (edge)
Please choose one (or "q" to quit): 1
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
Running Gradle task 'assembleDebug'...                             16.0s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...          55.0s
I/FlutterActivityAndFragmentDelegate(30555): If you are attempting to set --enable-dart-profiling via Intent extras to launch a Flutter component outside of using the Flutter CLI, note that support for setting engine flags on Android via Intent will soon be dropped; see https://github.com/flutter/flutter/issues/180686 for more information on this breaking change. To migrate, set --enable-dart-profiling or any other flags specified via Intent extras on the command line instead or see https://github.com/flutter/flutter/blob/main/docs/engine/Flutter-Android-Engine-Flags.md for alternative methods.
D/FlutterJNI(30555): Beginning load of flutter...
D/FlutterJNI(30555): flutter (null) was loaded normally!
I/flutter (30555): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
W/le.budget_budd(30555): Accessing hidden method Landroid/content/ContextWrapper;->getDisplay()Landroid/view/Display; (greylist, linking, allowed)
Syncing files to device SM G965F...                                233ms

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on SM G965F is available at: http://127.0.0.1:50700/rTGyEXcRd3A=/
The Flutter DevTools debugger and profiler on SM G965F is available at:
http://127.0.0.1:50700/rTGyEXcRd3A=/devtools/?uri=ws://127.0.0.1:50700/rTGyEXcRd3A=/ws
W/le.budget_budd(30555): Accessing hidden method Landroid/view/WindowInsets$Type;->systemBars()I (blacklist, linking, denied)
I/chatty  (30555): uid=10259(com.example.budget_buddy) identical 1 line
W/le.budget_budd(30555): Accessing hidden method Landroid/view/WindowInsets$Type;->systemBars()I (blacklist, linking, denied)
W/le.budget_budd(30555): Accessing hidden method Landroid/view/accessibility/AccessibilityNodeInfo;->getSourceNodeId()J (greylist, reflection, allowed)
W/le.budget_budd(30555): Accessing hidden method Landroid/view/accessibility/AccessibilityRecord;->getSourceNodeId()J (greylist, reflection, allowed)
W/le.budget_budd(30555): Accessing hidden field Landroid/view/accessibility/AccessibilityNodeInfo;->mChildNodeIds:Landroid/util/LongArray; (greylist, reflection, allowed)
W/le.budget_budd(30555): Accessing hidden method Landroid/util/LongArray;->get(I)J (greylist, reflection, allowed)
D/AccessibilityBridge(30555): Setting not found: accessibility_display_inversion_enabled, using default: 0
D/FlutterRenderer(30555): Width is zero. 0,0
I/ViewRootImpl@28841a9[MainActivity](30555): setView = com.android.internal.policy.DecorView@4c81ba4 TM=true MM=false
I/flutter (30555): ╔══════════════════════════════════════════════════════╗
I/flutter (30555): ║                 ISAR CONNECT STARTED                 ║
I/flutter (30555): ╟──────────────────────────────────────────────────────╢
I/flutter (30555): ║         Open the link to connect to the Isar         ║
I/flutter (30555): ║        Inspector while this build is running.        ║
I/flutter (30555): ╟──────────────────────────────────────────────────────╢
I/flutter (30555): ║ https://inspect.isar.dev/3.1.0+1/#/50700/rTGyEXcRd3A ║
I/flutter (30555): ╚══════════════════════════════════════════════════════╝
I/ViewRootImpl@28841a9[MainActivity](30555): stopped(true) old=false
I/Choreographer(30555): Skipped 1265 frames!  The application may be doing too much work on its main thread.
D/FlutterRenderer(30555): Width is zero. 0,0
D/FlutterRenderer(30555): Width is zero. 0,0
I/ViewRootImpl@28841a9[MainActivity](30555): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)8 dur=10 res=0x1 s={false 0} ch=false
I/ViewRootImpl@28841a9[MainActivity](30555): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)8 dur=8 res=0x1 s={false 0} ch=false
D/PhoneWindow(30555): forceLight changed to false [com.example.budget_buddy/com.example.budget_buddy.MainActivity] from com.android.internal.policy.PhoneWindow.updateForceLightNavigationBar:4280 com.android.internal.policy.PhoneWindow.setNavigationBarColor:4102 io.flutter.plugin.platform.PlatformPlugin.setSystemChromeSystemUIOverlayStyle:578 io.flutter.plugin.platform.PlatformPlugin.access$700:37 io.flutter.plugin.platform.PlatformPlugin$1.setSystemUiOverlayStyle:125
W/le.budget_budd(30555): Accessing hidden method Landroid/hardware/biometrics/BiometricManager;->canAuthenticate(I)I (blacklist, linking, denied)
I/chatty  (30555): uid=10259(com.example.budget_buddy) estorage.worker identical 2 lines
W/le.budget_budd(30555): Accessing hidden method Landroid/hardware/biometrics/BiometricManager;->canAuthenticate(I)I (blacklist, linking, denied)
I/ViewRootImpl@28841a9[MainActivity](30555): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)8 dur=10 res=0x1 s={false 0} ch=false
D/FlutterRenderer(30555): Width is zero. 0,0
D/FlutterRenderer(30555): Width is zero. 0,0
D/libmdf  (30555): libmdf v2.9.0.0 On 64bit PLATFORM
D/ProfileInstaller(30555): Installing profile for com.example.budget_buddy
I/SurfaceView(30555): onWindowVisibilityChanged(4) false io.flutter.embedding.android.FlutterSurfaceView{339e098 G.E...... ......I. 0,0-0,0} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity](30555): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)4 dur=6 res=0x1 s={false 0} ch=false
I/ViewRootImpl@28841a9[MainActivity](30555): stopped(false) old=true
I/SurfaceView(30555): windowStopped(false) false io.flutter.embedding.android.FlutterSurfaceView{339e098 G.E...... ......I. 0,0-0,0} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity](30555): stopped(false) old=false
I/SurfaceView(30555): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{339e098 V.E...... ......I. 0,0-0,0} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity](30555): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=11 res=0x7 s={true 530529718272} ch=true
D/FlutterJNI(30555): Sending viewport metrics to the engine.
I/mali_winsys(30555): new_window_surface() [1440x2960] return: 0x3000
I/SurfaceView(30555): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{339e098 V.E...... ......ID 0,0-1440,2792}
I/mali_winsys(30555): new_window_surface() [1440x2792] return: 0x3000
I/SurfaceView(30555): surfaceChanged (1440,2792) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{339e098 V.E...... ......ID 0,0-1440,2792}
I/mali_egl(30555): eglDestroySurface() in
I/mali_winsys(30555): delete_surface() [1440x2792] return
I/mali_egl(30555): eglDestroySurface() out
W/libEGL  (30555): EGLNativeWindowType 0x7b8d04c010 disconnect failed
I/mali_winsys(30555): new_window_surface() [1440x2792] return: 0x3000
I/ViewRootImpl@28841a9[MainActivity](30555): MSG_RESIZED_REPORT: frame=(0,0,1440,2960) ci=(0,84,0,168) vi=(0,84,0,168) or=1
I/ViewRootImpl@28841a9[MainActivity](30555): MSG_RESIZED_REPORT: frame=(0,0,1440,2960) ci=(0,84,0,168) vi=(0,84,0,168) or=1
W/Gralloc3(30555): mapper 3.x is not supported
I/gralloc (30555): Arm Module v1.0
I/OpenGLRenderer(30555): doUpdatePositionAsync is called and callVoidMethod
I/ViewRootImpl@28841a9[MainActivity](30555): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(30555): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager(30555): getNavigationBarColor() -16777216
D/InputMethodManager(30555): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager(30555): getNavigationBarColor() -16777216
V/InputMethodManager(30555): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(30555): startInputInner - Id : 0
I/InputMethodManager(30555): startInputInner - mService.startInputOrWindowGainedFocus
D/InputMethodManager(30555): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager(30555): getNavigationBarColor() -16777216
V/InputMethodManager(30555): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(30555): startInputInner - Id : 0
I/ViewRootImpl@28841a9[MainActivity](30555): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager(30555): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager(30555): getNavigationBarColor() -16777216
D/InputTransport(30555): Input channel destroyed: 'ClientS', fd=101
D/BiometricPrompt(30555): onAuthenticationSucceeded
I/ViewRootImpl@28841a9[MainActivity](30555): stopped(false) old=false
I/ViewRootImpl@28841a9[MainActivity](30555): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=7 res=0x1 s={true 530529718272} ch=false
I/ViewRootImpl@28841a9[MainActivity](30555): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(30555): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager(30555): getNavigationBarColor() -16777216
D/InputMethodManager(30555): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager(30555): getNavigationBarColor() -16777216
V/InputMethodManager(30555): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(30555): startInputInner - Id : 0
I/InputMethodManager(30555): startInputInner - mService.startInputOrWindowGainedFocus
Lost connection to device.
PS C:\dev\MobileDev\BudgetBuddy>
PS C:\dev\MobileDev\BudgetBuddy> flutter run
Waiting for another flutter command to release the startup lock...
Connected devices:
SM G965F (mobile) • 2291940c08037ece     • android-arm64  • Android 10 (API 29)
SM N950F (mobile) • 988a1b37395241584d30 • android-arm64  • Android 9 (API 28)
Windows (desktop) • windows              • windows-x64    • Microsoft Windows [Version
10.0.26300.9457]
Chrome (web)      • chrome               • web-javascript • Google Chrome 155.0.8059.39
Edge (web)        • edge                 • web-javascript • Microsoft Edge 155.0.4283.45
[1]: SM G965F (2291940c08037ece)
[2]: SM N950F (988a1b37395241584d30)
[3]: Windows (windows)
[4]: Chrome (chrome)
[5]: Edge (edge)
Please choose one (or "q" to quit): 1
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
Warning: SDK processing. This version only understands SDK XML versions up to 3 but an SDK XML file of version 4 was encountered. This can happen if you use versions of Android Studio and the command-line tools that were released at different times.
Running Gradle task 'assembleDebug'...                             32.6s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...          55.8s
I/FlutterActivityAndFragmentDelegate( 2185): If you are attempting to set --enable-dart-profiling via Intent extras to launch a Flutter component outside of using the Flutter CLI, note that support for setting engine flags on Android via Intent will soon be dropped; see https://github.com/flutter/flutter/issues/180686 for more information on this breaking change. To migrate, set --enable-dart-profiling or any other flags specified via Intent extras on the command line instead or see https://github.com/flutter/flutter/blob/main/docs/engine/Flutter-Android-Engine-Flags.md for alternative methods.
D/FlutterJNI( 2185): Beginning load of flutter...
D/FlutterJNI( 2185): flutter (null) was loaded normally!
I/flutter ( 2185): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
D/FlutterRenderer( 2185): Width is zero. 0,0
I/flutter ( 2185): ╔══════════════════════════════════════════════════════╗
I/flutter ( 2185): ║                 ISAR CONNECT STARTED                 ║
I/flutter ( 2185): ╟──────────────────────────────────────────────────────╢
I/flutter ( 2185): ║         Open the link to connect to the Isar         ║
I/flutter ( 2185): ║        Inspector while this build is running.        ║
I/flutter ( 2185): ╟──────────────────────────────────────────────────────╢
I/flutter ( 2185): ║ https://inspect.isar.dev/3.1.0+1/#/49793/4FPl3DgMnGo ║
I/flutter ( 2185): ╚══════════════════════════════════════════════════════╝
Syncing files to device SM G965F...                                611ms

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on SM G965F is available at: http://127.0.0.1:49793/4FPl3DgMnGo=/
The Flutter DevTools debugger and profiler on SM G965F is available at:
http://127.0.0.1:49793/4FPl3DgMnGo=/devtools/?uri=ws://127.0.0.1:49793/4FPl3DgMnGo=/ws
I/Choreographer( 2185): Skipped 374 frames!  The application may be doing too much work on its main thread.
I/SurfaceView( 2185): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......I. 0,0-0,0} of ViewRootImpl@28841a9[MainActivity]
D/FlutterRenderer( 2185): Width is zero. 0,0
D/FlutterRenderer( 2185): Width is zero. 0,0
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=15 res=0x7 s={true 530713055232} ch=true
D/FlutterJNI( 2185): Sending viewport metrics to the engine.
I/mali_winsys( 2185): new_window_surface() [1440x2960] return: 0x3000
I/SurfaceView( 2185): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792}
I/mali_winsys( 2185): new_window_surface() [1440x2792] return: 0x3000
I/SurfaceView( 2185): surfaceChanged (1440,2792) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2792] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x7b8618e010 disconnect failed
I/mali_winsys( 2185): new_window_surface() [1440x2792] return: 0x3000
W/Gralloc3( 2185): mapper 3.x is not supported
I/gralloc ( 2185): Arm Module v1.0
I/Choreographer( 2185): Skipped 158 frames!  The application may be doing too much work on its main thread.
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=8 res=0x3 s={true 530713055232} ch=false
D/PhoneWindow( 2185): forceLight changed to false [com.example.budget_buddy/com.example.budget_buddy.MainActivity] from com.android.internal.policy.PhoneWindow.updateForceLightNavigationBar:4280 com.android.internal.policy.PhoneWindow.setNavigationBarColor:4102 io.flutter.plugin.platform.PlatformPlugin.setSystemChromeSystemUIOverlayStyle:578 io.flutter.plugin.platform.PlatformPlugin.access$700:37 io.flutter.plugin.platform.PlatformPlugin$1.setSystemUiOverlayStyle:125
W/le.budget_budd( 2185): Accessing hidden method Landroid/hardware/biometrics/BiometricManager;->canAuthenticate(I)I (blacklist, linking, denied)
I/chatty  ( 2185): uid=10259(com.example.budget_buddy) estorage.worker identical 2 lines
W/le.budget_budd( 2185): Accessing hidden method Landroid/hardware/biometrics/BiometricManager;->canAuthenticate(I)I (blacklist, linking, denied)
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=9 res=0x3 s={true 530713055232} ch=false
D/FlutterJNI( 2185): Sending viewport metrics to the engine.
I/OpenGLRenderer( 2185): doUpdatePositionAsync is called and callVoidMethod
D/libmdf  ( 2185): libmdf v2.9.0.0 On 64bit PLATFORM
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
V/InputMethodManager( 2185): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 2185): startInputInner - Id : 0
I/InputMethodManager( 2185): startInputInner - mService.startInputOrWindowGainedFocus
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_RESIZED_REPORT: frame=(0,0,1440,2960) ci=(0,84,0,168) vi=(0,84,0,168) or=1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
V/InputMethodManager( 2185): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 2185): startInputInner - Id : 0
D/FlutterJNI( 2185): Sending viewport metrics to the engine.
D/ProfileInstaller( 2185): Installing profile for com.example.budget_buddy
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
D/InputTransport( 2185): Input channel destroyed: 'ClientS', fd=103
I/SurfaceView( 2185): onWindowVisibilityChanged(8) false io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/SurfaceView( 2185): surfaceDestroyed callback.size 1 #2 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792}
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2792] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x7b8618e010 disconnect failed
I/SurfaceView( 2185): remove() io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792} Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@117b05c@0)/@0x4f2e99d
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2960] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x7b90f8a2d0 disconnect failed
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)8 dur=9 res=0x5 s={false 0} ch=true
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(true) old=false
I/SurfaceView( 2185): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
D/BiometricPrompt( 2185): onAuthenticationSucceeded
I/SurfaceView( 2185): onWindowVisibilityChanged(4) false io.flutter.embedding.android.FlutterSurfaceView{117b05c G.E...... ......I. 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)4 dur=4 res=0x1 s={false 0} ch=false
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(false) old=true
I/SurfaceView( 2185): windowStopped(false) false io.flutter.embedding.android.FlutterSurfaceView{117b05c G.E...... ......I. 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(false) old=false
I/SurfaceView( 2185): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=6 res=0x7 s={true 530713067520} ch=true
I/mali_winsys( 2185): new_window_surface() [1440x2960] return: 0x3000
I/SurfaceView( 2185): surfaceCreated 1 #5 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792}
I/mali_winsys( 2185): new_window_surface() [1440x2792] return: 0x3000
I/SurfaceView( 2185): surfaceChanged (1440,2792) 1 #5 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2792] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x78b2607010 disconnect failed
I/mali_winsys( 2185): new_window_surface() [1440x2792] return: 0x3000
I/OpenGLRenderer( 2185): doUpdatePositionAsync is called and callVoidMethod
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
V/InputMethodManager( 2185): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 2185): startInputInner - Id : 0
I/InputMethodManager( 2185): startInputInner - mService.startInputOrWindowGainedFocus
D/BiometricPrompt( 2185): onAuthenticationSucceeded
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
D/InputTransport( 2185): Input channel destroyed: 'ClientS', fd=102
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(true) old=false
I/SurfaceView( 2185): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/SurfaceView( 2185): surfaceDestroyed callback.size 1 #1 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792}
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2792] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x78b2607010 disconnect failed
I/SurfaceView( 2185): remove() io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792} Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@117b05c@1)/@0xf92ea3b
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(false) old=true
I/SurfaceView( 2185): windowStopped(false) false io.flutter.embedding.android.FlutterSurfaceView{117b05c G.E...... ......I. 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(false) old=false
I/Choreographer( 2185): Skipped 138 frames!  The application may be doing too much work on its main thread.
I/SurfaceView( 2185): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2960] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x7b90f8a2d0 disconnect failed
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=6 res=0x3 s={true 519689220096} ch=true
I/mali_winsys( 2185): new_window_surface() [1440x2960] return: 0x3000
I/SurfaceView( 2185): surfaceCreated 1 #5 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792}
I/mali_winsys( 2185): new_window_surface() [1440x2792] return: 0x3000
I/SurfaceView( 2185): surfaceChanged (1440,2792) 1 #5 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2792] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x78ffe61010 disconnect failed
I/mali_winsys( 2185): new_window_surface() [1440x2792] return: 0x3000
I/OpenGLRenderer( 2185): doUpdatePositionAsync is called and callVoidMethod
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_RESIZED_REPORT: frame=(0,0,1440,2960) ci=(0,84,0,168) vi=(0,84,0,168) or=1
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
V/InputMethodManager( 2185): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 2185): startInputInner - Id : 0
I/InputMethodManager( 2185): startInputInner - mService.startInputOrWindowGainedFocus
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
V/InputMethodManager( 2185): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 2185): startInputInner - Id : 0
I/InputMethodManager( 2185): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport( 2185): Input channel destroyed: 'ClientS', fd=103
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(true) old=false
I/SurfaceView( 2185): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/SurfaceView( 2185): surfaceDestroyed callback.size 1 #1 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792}
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2792] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x78ffe61010 disconnect failed
I/SurfaceView( 2185): remove() io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ........ 0,0-1440,2792} Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@117b05c@2)/@0xb7421a3
E/ViewRootImpl@28841a9[MainActivity]( 2185): Surface is not valid.
I/SurfaceView( 2185): onWindowVisibilityChanged(8) false io.flutter.embedding.android.FlutterSurfaceView{117b05c G.E...... ......I. 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2960] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x7b90f8a2d0 disconnect failed
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)8 dur=9 res=0x5 s={false 0} ch=false
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(false) old=true
I/SurfaceView( 2185): windowStopped(false) false io.flutter.embedding.android.FlutterSurfaceView{117b05c G.E...... ......I. 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity]( 2185): stopped(false) old=false
I/SurfaceView( 2185): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792} of ViewRootImpl@28841a9[MainActivity]
I/ViewRootImpl@28841a9[MainActivity]( 2185): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=10 res=0x7 s={true 519689224192} ch=true
I/mali_winsys( 2185): new_window_surface() [1440x2960] return: 0x3000
I/SurfaceView( 2185): surfaceCreated 1 #5 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792}
I/mali_winsys( 2185): new_window_surface() [1440x2792] return: 0x3000
I/SurfaceView( 2185): surfaceChanged (1440,2792) 1 #5 io.flutter.embedding.android.FlutterSurfaceView{117b05c V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 2185): eglDestroySurface() in
I/mali_winsys( 2185): delete_surface() [1440x2792] return
I/mali_egl( 2185): eglDestroySurface() out
W/libEGL  ( 2185): EGLNativeWindowType 0x7b8cfdf010 disconnect failed
I/mali_winsys( 2185): new_window_surface() [1440x2792] return: 0x3000
I/OpenGLRenderer( 2185): doUpdatePositionAsync is called and callVoidMethod
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_RESIZED_REPORT: frame=(0,0,1440,2960) ci=(0,84,0,168) vi=(0,84,0,168) or=1
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
V/InputMethodManager( 2185): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 2185): startInputInner - Id : 0
I/InputMethodManager( 2185): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport( 2185): Input channel destroyed: 'ClientS', fd=144
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216
I/ViewRootImpl@28841a9[MainActivity]( 2185): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 2185): prepareNavigationBarInfo() DecorView@4c81ba4[MainActivity]
D/InputMethodManager( 2185): getNavigationBarColor() -16777216

PHONE A - THIS IS THE PHONE WITH THE SHARED SPACE AND IS ADDING PHONE B

PS C:\dev\MobileDev\BudgetBuddy> flutter run
Connected devices:
SM G965F (mobile) • 2291940c08037ece     • android-arm64  • Android 10 (API 29)
SM N950F (mobile) • 988a1b37395241584d30 • android-arm64  • Android 9 (API 28)
Windows (desktop) • windows              • windows-x64    • Microsoft Windows [Version 10.0.26300.9457]
Chrome (web)      • chrome               • web-javascript • Google Chrome 155.0.8059.39
Edge (web)        • edge                 • web-javascript • Microsoft Edge 155.0.4283.45
[1]: SM G965F (2291940c08037ece)
[2]: SM N950F (988a1b37395241584d30)
[3]: Windows (windows)
[4]: Chrome (chrome)
[5]: Edge (edge)
Please choose one (or "q" to quit): 2
Launching lib\main.dart on SM N950F in debug mode...
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
Running Gradle task 'assembleDebug'...                             27.5s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...              |Terminate batch job (Y/N)?
^C
PS C:\dev\MobileDev\BudgetBuddy> ^C
PS C:\dev\MobileDev\BudgetBuddy> ^C
PS C:\dev\MobileDev\BudgetBuddy>
PS C:\dev\MobileDev\BudgetBuddy> flutter run
Connected devices:
SM G965F (mobile) • 2291940c08037ece     • android-arm64  • Android 10 (API 29)
SM N950F (mobile) • 988a1b37395241584d30 • android-arm64  • Android 9 (API 28)
Windows (desktop) • windows              • windows-x64    • Microsoft Windows [Version 10.0.26300.9457]
Chrome (web)      • chrome               • web-javascript • Google Chrome 155.0.8059.39
Edge (web)        • edge                 • web-javascript • Microsoft Edge 155.0.4283.45
[1]: SM G965F (2291940c08037ece)
[2]: SM N950F (988a1b37395241584d30)
[3]: Windows (windows)
[4]: Chrome (chrome)
[5]: Edge (edge)
Please choose one (or "q" to quit): 2
Launching lib\main.dart on SM N950F in debug mode...
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
Running Gradle task 'assembleDebug'...                              5.2s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...          11.4s
Error: ADB exited with exit code 1
Performing Streamed Install

adb.exe: failed to install C:\dev\MobileDev\BudgetBuddy\build\app\outputs\flutter-apk\app-debug.apk:
Error launching application on SM N950F.
PS C:\dev\MobileDev\BudgetBuddy> flutter run
Connected devices:
SM G965F (mobile) • 2291940c08037ece     • android-arm64  • Android 10 (API 29)
SM N950F (mobile) • 988a1b37395241584d30 • android-arm64  • Android 9 (API 28)
Windows (desktop) • windows              • windows-x64    • Microsoft Windows [Version 10.0.26300.9457]
Chrome (web)      • chrome               • web-javascript • Google Chrome 155.0.8059.39
Edge (web)        • edge                 • web-javascript • Microsoft Edge 155.0.4283.45
[1]: SM G965F (2291940c08037ece)
[2]: SM N950F (988a1b37395241584d30)
[3]: Windows (windows)
[4]: Chrome (chrome)
[5]: Edge (edge)
Please choose one (or "q" to quit): 2
Launching lib\main.dart on SM N950F in debug mode...
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
Running Gradle task 'assembleDebug'...                              5.3s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...          24.3s
I/FlutterActivityAndFragmentDelegate(13508): If you are attempting to set --enable-dart-profiling via Intent extras to launch a Flutter component outside of using the Flutter CLI, note that support for setting engine flags on Android via Intent will soon be dropped; see https://github.com/flutter/flutter/issues/180686 for more information on this breaking change. To migrate, set --enable-dart-profiling or any other flags specified via Intent extras on the command line instead or see https://github.com/flutter/flutter/blob/main/docs/engine/Flutter-Android-Engine-Flags.md for alternative methods.
D/FlutterJNI(13508): Beginning load of flutter...
D/FlutterJNI(13508): flutter (null) was loaded normally!
I/flutter (13508): [IMPORTANT:flutter/shell/common/shell.cc(528)] [Action Required]: Impeller opt-out deprecated.
I/flutter (13508):     The application opted out of Impeller by either using the
I/flutter (13508):     `--no-enable-impeller` flag or the
I/flutter (13508):     `io.flutter.embedding.android.EnableImpeller` `AndroidManifest.xml` entry.
I/flutter (13508):     These options are going to go away in an upcoming Flutter release. Remove
I/flutter (13508):     the explicit opt-out. If you need to opt-out, please report a bug describing
I/flutter (13508):     the issue.
I/flutter (13508):
I/flutter (13508):     https://github.com/flutter/flutter/issues/new?template=02_bug.yml
I/flutter (13508):
D/FlutterRenderer(13508): Width is zero. 0,0
W/le.budget_budd(13508): Accessing hidden method Landroid/os/Trace;->asyncTraceBegin(JLjava/lang/String;I)V (light greylist, reflection)
Syncing files to device SM N950F...                                233ms

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on SM N950F is available at: http://127.0.0.1:59793/Trv9gyMk5EQ=/
The Flutter DevTools debugger and profiler on SM N950F is available at:
http://127.0.0.1:59793/Trv9gyMk5EQ=/devtools/?uri=ws://127.0.0.1:59793/Trv9gyMk5EQ=/ws
I/flutter (13508): ╔══════════════════════════════════════════════════════╗
I/flutter (13508): ║                 ISAR CONNECT STARTED                 ║
I/flutter (13508): ╟──────────────────────────────────────────────────────╢
I/flutter (13508): ║         Open the link to connect to the Isar         ║
I/flutter (13508): ║        Inspector while this build is running.        ║
I/flutter (13508): ╟──────────────────────────────────────────────────────╢
I/flutter (13508): ║ https://inspect.isar.dev/3.1.0+1/#/59793/Trv9gyMk5EQ ║
I/flutter (13508): ╚══════════════════════════════════════════════════════╝
I/Choreographer(13508): Skipped 433 frames!  The application may be doing too much work on its main thread.
I/le.budget_budd(13508): Rejecting re-init on previously-failed class java.lang.Class<androidx.window.layout.adapter.sidecar.DistinctElementSidecarCallback>: java.lang.NoClassDefFoundError: Failed resolution of: Landroidx/window/sidecar/SidecarInterface$SidecarCallback;
I/le.budget_budd(13508):   at androidx.window.layout.adapter.sidecar.ExtensionInterfaceCompat androidx.window.layout.adapter.sidecar.SidecarWindowBackend$Companion.initAndVerifyExtension(android.content.Context) (SidecarWindowBackend.kt:207)
I/le.budget_budd(13508):   at androidx.window.layout.adapter.sidecar.SidecarWindowBackend androidx.window.layout.adapter.sidecar.SidecarWindowBackend$Companion.getInstance(android.content.Context) (SidecarWindowBackend.kt:191)
I/le.budget_budd(13508):   at androidx.window.layout.WindowInfoTracker androidx.window.layout.WindowInfoTracker$Companion.getOrCreate(android.content.Context) (WindowInfoTracker.kt:135)
I/le.budget_budd(13508):   at io.flutter.embedding.android.WindowInfoRepositoryCallbackAdapterWrapper io.flutter.embedding.android.FlutterView.createWindowInfoRepo() (FlutterView.java:547)
I/le.budget_budd(13508):   at void io.flutter.embedding.android.FlutterView.onAttachedToWindow() (FlutterView.java:568)
I/le.budget_budd(13508):   at void android.view.View.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (View.java:20021)
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3589)
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3596)
I/chatty  (13508): uid=10205(com.example.budget_buddy) identical 2 lines
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3596)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl.performTraversals() (ViewRootImpl.java:2208)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl.doTraversal() (ViewRootImpl.java:1873)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl$TraversalRunnable.run() (ViewRootImpl.java:8496)
I/le.budget_budd(13508):   at void android.view.Choreographer$CallbackRecord.run(long) (Choreographer.java:986)
I/le.budget_budd(13508):   at void android.view.Choreographer.doCallbacks(int, long) (Choreographer.java:764)
I/le.budget_budd(13508):   at void android.view.Choreographer.doFrame(long, int) (Choreographer.java:699)
I/le.budget_budd(13508):   at void android.view.Choreographer$FrameDisplayEventReceiver.run() (Choreographer.java:965)
I/le.budget_budd(13508):   at void android.os.Handler.handleCallback(android.os.Message) (Handler.java:873)
I/le.budget_budd(13508):   at void android.os.Handler.dispatchMessage(android.os.Message) (Handler.java:99)
I/le.budget_budd(13508):   at void android.os.Looper.loop() (Looper.java:214)
I/le.budget_budd(13508):   at void android.app.ActivityThread.main(java.lang.String[]) (ActivityThread.java:7073)
I/le.budget_budd(13508):   at java.lang.Object java.lang.reflect.Method.invoke(java.lang.Object, java.lang.Object[]) (Method.java:-2)
I/le.budget_budd(13508):   at void com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run() (RuntimeInit.java:494)
I/le.budget_budd(13508):   at void com.android.internal.os.ZygoteInit.main(java.lang.String[]) (ZygoteInit.java:965)
I/le.budget_budd(13508): Caused by: java.lang.ClassNotFoundException: Didn't find class "androidx.window.sidecar.SidecarInterface$SidecarCallback" on path: DexPathList[[zip file "/data/app/com.example.budget_buddy-No2j05d0a1BUGoI7bcJ41g==/base.apk"],nativeLibraryDirectories=[/data/app/com.example.budget_buddy-No2j05d0a1BUGoI7bcJ41g==/lib/arm64, /data/app/com.example.budget_buddy-No2j05d0a1BUGoI7bcJ41g==/base.apk!/lib/arm64-v8a, /system/lib64, /system/vendor/lib64]]
I/le.budget_budd(13508):   at java.lang.Class dalvik.system.BaseDexClassLoader.findClass(java.lang.String) (BaseDexClassLoader.java:134)
I/le.budget_budd(13508):   at java.lang.Class java.lang.ClassLoader.loadClass(java.lang.String, boolean) (ClassLoader.java:379)
I/le.budget_budd(13508):   at java.lang.Class java.lang.ClassLoader.loadClass(java.lang.String) (ClassLoader.java:312)
I/le.budget_budd(13508):   at androidx.window.layout.adapter.sidecar.ExtensionInterfaceCompat androidx.window.layout.adapter.sidecar.SidecarWindowBackend$Companion.initAndVerifyExtension(android.content.Context) (SidecarWindowBackend.kt:207)
I/le.budget_budd(13508):   at androidx.window.layout.adapter.sidecar.SidecarWindowBackend androidx.window.layout.adapter.sidecar.SidecarWindowBackend$Companion.getInstance(android.content.Context) (SidecarWindowBackend.kt:191)
I/le.budget_budd(13508):   at androidx.window.layout.WindowInfoTracker androidx.window.layout.WindowInfoTracker$Companion.getOrCreate(android.content.Context) (WindowInfoTracker.kt:135)
I/le.budget_budd(13508):   at io.flutter.embedding.android.WindowInfoRepositoryCallbackAdapterWrapper io.flutter.embedding.android.FlutterView.createWindowInfoRepo() (FlutterView.java:547)
I/le.budget_budd(13508):   at void io.flutter.embedding.android.FlutterView.onAttachedToWindow() (FlutterView.java:568)
I/le.budget_budd(13508):   at void android.view.View.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (View.java:20021)
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3589)
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3596)
I/chatty  (13508): uid=10205(com.example.budget_buddy) identical 2 lines
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3596)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl.performTraversals() (ViewRootImpl.java:2208)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl.doTraversal() (ViewRootImpl.java:1873)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl$TraversalRunnable.run() (ViewRootImpl.java:8496)
I/le.budget_budd(13508):   at void android.view.Choreographer$CallbackRecord.run(long) (Choreographer.java:986)
I/le.budget_budd(13508):   at void android.view.Choreographer.doCallbacks(int, long) (Choreographer.java:764)
I/le.budget_budd(13508):   at void android.view.Choreographer.doFrame(long, int) (Choreographer.java:699)
I/le.budget_budd(13508):   at void android.view.Choreographer$FrameDisplayEventReceiver.run() (Choreographer.java:965)
I/le.budget_budd(13508):   at void android.os.Handler.handleCallback(android.os.Message) (Handler.java:873)
I/le.budget_budd(13508):   at void android.os.Handler.dispatchMessage(android.os.Message) (Handler.java:99)
I/le.budget_budd(13508):   at void android.os.Looper.loop() (Looper.java:214)
I/le.budget_budd(13508):   at void android.app.ActivityThread.main(java.lang.String[]) (ActivityThread.java:7073)
I/le.budget_budd(13508):   at java.lang.Object java.lang.reflect.Method.invoke(java.lang.Object, java.lang.Object[]) (Method.java:-2)
I/le.budget_budd(13508):   at void com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run() (RuntimeInit.java:494)
I/le.budget_budd(13508):   at void com.android.internal.os.ZygoteInit.main(java.lang.String[]) (ZygoteInit.java:965)
I/le.budget_budd(13508):
I/le.budget_budd(13508): Rejecting re-init on previously-failed class java.lang.Class<androidx.window.layout.adapter.sidecar.DistinctElementSidecarCallback>: java.lang.NoClassDefFoundError: Failed resolution of: Landroidx/window/sidecar/SidecarInterface$SidecarCallback;
I/le.budget_budd(13508):   at androidx.window.layout.adapter.sidecar.ExtensionInterfaceCompat androidx.window.layout.adapter.sidecar.SidecarWindowBackend$Companion.initAndVerifyExtension(android.content.Context) (SidecarWindowBackend.kt:207)
I/le.budget_budd(13508):   at androidx.window.layout.adapter.sidecar.SidecarWindowBackend androidx.window.layout.adapter.sidecar.SidecarWindowBackend$Companion.getInstance(android.content.Context) (SidecarWindowBackend.kt:191)
I/le.budget_budd(13508):   at androidx.window.layout.WindowInfoTracker androidx.window.layout.WindowInfoTracker$Companion.getOrCreate(android.content.Context) (WindowInfoTracker.kt:135)
I/le.budget_budd(13508):   at io.flutter.embedding.android.WindowInfoRepositoryCallbackAdapterWrapper io.flutter.embedding.android.FlutterView.createWindowInfoRepo() (FlutterView.java:547)
I/le.budget_budd(13508):   at void io.flutter.embedding.android.FlutterView.onAttachedToWindow() (FlutterView.java:568)
I/le.budget_budd(13508):   at void android.view.View.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (View.java:20021)
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3589)
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3596)
I/chatty  (13508): uid=10205(com.example.budget_buddy) identical 2 lines
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3596)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl.performTraversals() (ViewRootImpl.java:2208)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl.doTraversal() (ViewRootImpl.java:1873)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl$TraversalRunnable.run() (ViewRootImpl.java:8496)
I/le.budget_budd(13508):   at void android.view.Choreographer$CallbackRecord.run(long) (Choreographer.java:986)
I/le.budget_budd(13508):   at void android.view.Choreographer.doCallbacks(int, long) (Choreographer.java:764)
I/le.budget_budd(13508):   at void android.view.Choreographer.doFrame(long, int) (Choreographer.java:699)
I/le.budget_budd(13508):   at void android.view.Choreographer$FrameDisplayEventReceiver.run() (Choreographer.java:965)
I/le.budget_budd(13508):   at void android.os.Handler.handleCallback(android.os.Message) (Handler.java:873)
I/le.budget_budd(13508):   at void android.os.Handler.dispatchMessage(android.os.Message) (Handler.java:99)
I/le.budget_budd(13508):   at void android.os.Looper.loop() (Looper.java:214)
I/le.budget_budd(13508):   at void android.app.ActivityThread.main(java.lang.String[]) (ActivityThread.java:7073)
I/le.budget_budd(13508):   at java.lang.Object java.lang.reflect.Method.invoke(java.lang.Object, java.lang.Object[]) (Method.java:-2)
I/le.budget_budd(13508):   at void com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run() (RuntimeInit.java:494)
I/le.budget_budd(13508):   at void com.android.internal.os.ZygoteInit.main(java.lang.String[]) (ZygoteInit.java:965)
I/le.budget_budd(13508): Caused by: java.lang.ClassNotFoundException: Didn't find class "androidx.window.sidecar.SidecarInterface$SidecarCallback" on path: DexPathList[[zip file "/data/app/com.example.budget_buddy-No2j05d0a1BUGoI7bcJ41g==/base.apk"],nativeLibraryDirectories=[/data/app/com.example.budget_buddy-No2j05d0a1BUGoI7bcJ41g==/lib/arm64, /data/app/com.example.budget_buddy-No2j05d0a1BUGoI7bcJ41g==/base.apk!/lib/arm64-v8a, /system/lib64, /system/vendor/lib64]]
I/le.budget_budd(13508):   at java.lang.Class dalvik.system.BaseDexClassLoader.findClass(java.lang.String) (BaseDexClassLoader.java:134)
I/le.budget_budd(13508):   at java.lang.Class java.lang.ClassLoader.loadClass(java.lang.String, boolean) (ClassLoader.java:379)
I/le.budget_budd(13508):   at java.lang.Class java.lang.ClassLoader.loadClass(java.lang.String) (ClassLoader.java:312)
I/le.budget_budd(13508):   at androidx.window.layout.adapter.sidecar.ExtensionInterfaceCompat androidx.window.layout.adapter.sidecar.SidecarWindowBackend$Companion.initAndVerifyExtension(android.content.Context) (SidecarWindowBackend.kt:207)
I/le.budget_budd(13508):   at androidx.window.layout.adapter.sidecar.SidecarWindowBackend androidx.window.layout.adapter.sidecar.SidecarWindowBackend$Companion.getInstance(android.content.Context) (SidecarWindowBackend.kt:191)
I/le.budget_budd(13508):   at androidx.window.layout.WindowInfoTracker androidx.window.layout.WindowInfoTracker$Companion.getOrCreate(android.content.Context) (WindowInfoTracker.kt:135)
I/le.budget_budd(13508):   at io.flutter.embedding.android.WindowInfoRepositoryCallbackAdapterWrapper io.flutter.embedding.android.FlutterView.createWindowInfoRepo() (FlutterView.java:547)
I/le.budget_budd(13508):   at void io.flutter.embedding.android.FlutterView.onAttachedToWindow() (FlutterView.java:568)
I/le.budget_budd(13508):   at void android.view.View.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (View.java:20021)
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3589)
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3596)
I/chatty  (13508): uid=10205(com.example.budget_buddy) identical 2 lines
I/le.budget_budd(13508):   at void android.view.ViewGroup.dispatchAttachedToWindow(android.view.View$AttachInfo, int) (ViewGroup.java:3596)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl.performTraversals() (ViewRootImpl.java:2208)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl.doTraversal() (ViewRootImpl.java:1873)
I/le.budget_budd(13508):   at void android.view.ViewRootImpl$TraversalRunnable.run() (ViewRootImpl.java:8496)
I/le.budget_budd(13508):   at void android.view.Choreographer$CallbackRecord.run(long) (Choreographer.java:986)
I/le.budget_budd(13508):   at void android.view.Choreographer.doCallbacks(int, long) (Choreographer.java:764)
I/le.budget_budd(13508):   at void android.view.Choreographer.doFrame(long, int) (Choreographer.java:699)
I/le.budget_budd(13508):   at void android.view.Choreographer$FrameDisplayEventReceiver.run() (Choreographer.java:965)
I/le.budget_budd(13508):   at void android.os.Handler.handleCallback(android.os.Message) (Handler.java:873)
I/le.budget_budd(13508):   at void android.os.Handler.dispatchMessage(android.os.Message) (Handler.java:99)
I/le.budget_budd(13508):   at void android.os.Looper.loop() (Looper.java:214)
I/le.budget_budd(13508):   at void android.app.ActivityThread.main(java.lang.String[]) (ActivityThread.java:7073)
I/le.budget_budd(13508):   at java.lang.Object java.lang.reflect.Method.invoke(java.lang.Object, java.lang.Object[]) (Method.java:-2)
I/le.budget_budd(13508):   at void com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run() (RuntimeInit.java:494)
I/le.budget_budd(13508):   at void com.android.internal.os.ZygoteInit.main(java.lang.String[]) (ZygoteInit.java:965)
I/le.budget_budd(13508):
D/SurfaceView(13508): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......I. 0,0-0,0} of ViewRootImpl@3185f49[MainActivity]
D/ViewRootImpl@3185f49[MainActivity](13508): dispatchAttachedToWindow
D/FlutterRenderer(13508): Width is zero. 0,0
D/FlutterRenderer(13508): Width is zero. 0,0
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x7 surface={valid=true 517475262464} changed=true
I/OpenGLRenderer(13508): Initialized EGL, version 1.4
D/OpenGLRenderer(13508): Swap behavior 2
D/FlutterJNI(13508): Sending viewport metrics to the engine.
D/mali_winsys(13508): EGLint new_window_surface(egl_winsys_display *, void *, EGLSurface, EGLConfig, egl_winsys_surface **, EGLBoolean) returns 0x3000
D/OpenGLRenderer(13508): eglCreateWindowSurface = 0x787c21e580, 0x787bede010
D/SurfaceView(13508): show() Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@5f156f@0[13508])/@0x3de227c io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/SurfaceView(13508): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/mali_winsys(13508): EGLint new_window_surface(egl_winsys_display *, void *, EGLSurface, EGLConfig, egl_winsys_surface **, EGLBoolean) returns 0x3000
D/SurfaceView(13508): surfaceChanged (1440,2792) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x3 surface={valid=true 517475262464} changed=false
D/vndksupport(13508): Loading /vendor/lib64/hw/android.hardware.graphics.mapper@2.0-impl.so from current namespace instead of sphal namespace.
W/le.budget_budd(13508): Accessing hidden method Landroid/os/Trace;->asyncTraceEnd(JLjava/lang/String;I)V (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden method Landroid/os/Trace;->traceCounter(JLjava/lang/String;I)V (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden method Landroid/graphics/FontFamily;-><init>()V (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden method Landroid/graphics/FontFamily;->addFontFromAssetManager(Landroid/content/res/AssetManager;Ljava/lang/String;IZIII[Landroid/graphics/fonts/FontVariationAxis;)Z (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden method Landroid/graphics/FontFamily;->addFontFromBuffer(Ljava/nio/ByteBuffer;I[Landroid/graphics/fonts/FontVariationAxis;II)Z (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden method Landroid/graphics/FontFamily;->freeze()Z (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden method Landroid/graphics/FontFamily;->abortCreation()V (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden method Landroid/graphics/Typeface;->createFromFamiliesWithDefault([Landroid/graphics/FontFamily;Ljava/lang/String;II)Landroid/graphics/Typeface; (light greylist, reflection)
I/Choreographer(13508): Skipped 196 frames!  The application may be doing too much work on its main thread.
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x3 surface={valid=true 517475262464} changed=false
D/FlutterJNI(13508): Sending viewport metrics to the engine.
I/OpenGLRenderer(13508): Davey! duration=3377ms; Flags=1, IntendedVsync=57881237478869, Vsync=57884504145405, OldestInputEvent=9223372036854775807, NewestInputEvent=0, HandleInputStart=57884517708443, AnimationStart=57884517760020, PerformTraversalsStart=57884517764597, DrawStart=57884557508173, SyncQueued=57884559005904, SyncStart=57884559327673, IssueDrawCommandsStart=57884560001827, SwapBuffers=57884612844366, FrameCompleted=57884615174404, DequeueBufferDuration=5846000, QueueBufferDuration=919000,
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_RESIZED: frame=Rect(0, 0 - 1440, 2960) ci=Rect(0, 84 - 0, 168) vi=Rect(0, 84 - 0, 168) or=1
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
V/InputMethodManager(13508): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(13508): startInputInner - Id : 0
I/InputMethodManager(13508): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport(13508): Input channel constructed: fd=100
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
V/InputMethodManager(13508): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(13508): startInputInner - Id : 0
D/FlutterJNI(13508): Sending viewport metrics to the engine.
D/ProfileInstaller(13508): Installing profile for com.example.budget_buddy
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
D/InputTransport(13508): Input channel destroyed: fd=100
D/SurfaceView(13508): onWindowVisibilityChanged(8) false io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792} of ViewRootImpl@3185f49[MainActivity]
D/SurfaceView(13508): show() Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@5f156f@0[13508])/@0x3de227c io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792}
D/SurfaceView(13508): surfaceDestroyed callback.size 1 #2 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792}
W/libEGL  (13508): EGLNativeWindowType 0x787c19e010 disconnect failed
D/SurfaceView(13508): destroy() Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@5f156f@0[13508])/@0x3de227c io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792}
W/libEGL  (13508): EGLNativeWindowType 0x787bede010 disconnect failed
D/OpenGLRenderer(13508): eglDestroySurface = 0x787c21e580, 0x787bede000
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x5 surface={valid=false 0} changed=true
D/ViewRootImpl@3185f49[MainActivity](13508): setWindowStopped(true) old=false
D/SurfaceView(13508): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792} of ViewRootImpl@3185f49[MainActivity]
D/ViewRootImpl@3185f49[MainActivity](13508): Surface release. android.view.WindowManagerGlobal.setStoppedState:669 android.app.Activity.performStop:7650 android.app.ActivityThread.callActivityOnStop:4402 android.app.ActivityThread.performStopActivityInner:4380 android.app.ActivityThread.handleStopActivity:4455 android.app.servertransaction.StopActivityItem.execute:41 android.app.servertransaction.TransactionExecutor.executeLifecycleState:145 android.app.servertransaction.TransactionExecutor.execute:70
D/SurfaceView(13508): onWindowVisibilityChanged(4) false io.flutter.embedding.android.FlutterSurfaceView{5f156f G.E...... ......I. 0,0-1440,2792} of ViewRootImpl@3185f49[MainActivity]
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x1 surface={valid=false 0} changed=false
D/FlutterJNI(13508): Sending viewport metrics to the engine.
W/BiometricFragment(13508): Success not sent to client. Client is not awaiting a result.
D/ViewRootImpl@3185f49[MainActivity](13508): setWindowStopped(false) old=true
D/SurfaceView(13508): windowStopped(false) false io.flutter.embedding.android.FlutterSurfaceView{5f156f G.E...... ......I. 0,0-1440,2792} of ViewRootImpl@3185f49[MainActivity]
D/ViewRootImpl@3185f49[MainActivity](13508): setWindowStopped(false) old=false
D/SurfaceView(13508): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792} of ViewRootImpl@3185f49[MainActivity]
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x7 surface={valid=true 517475262464} changed=true
D/FlutterJNI(13508): Sending viewport metrics to the engine.
D/mali_winsys(13508): EGLint new_window_surface(egl_winsys_display *, void *, EGLSurface, EGLConfig, egl_winsys_surface **, EGLBoolean) returns 0x3000
D/OpenGLRenderer(13508): eglCreateWindowSurface = 0x787c21e580, 0x787bede010
D/SurfaceView(13508): show() Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@5f156f@1[13508])/@0xc7704c2 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/SurfaceView(13508): surfaceCreated 1 #5 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/mali_winsys(13508): EGLint new_window_surface(egl_winsys_display *, void *, EGLSurface, EGLConfig, egl_winsys_surface **, EGLBoolean) returns 0x3000
D/SurfaceView(13508): surfaceChanged (1440,2792) 1 #5 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_RESIZED: frame=Rect(0, 0 - 1440, 2960) ci=Rect(0, 84 - 0, 168) vi=Rect(0, 84 - 0, 168) or=1
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
V/InputMethodManager(13508): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(13508): startInputInner - Id : 0
I/InputMethodManager(13508): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport(13508): Input channel constructed: fd=100
I/Choreographer(13508): Skipped 74 frames!  The application may be doing too much work on its main thread.
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
I/OpenGLRenderer(13508): Davey! duration=1254ms; Flags=0, IntendedVsync=57943328221509, Vsync=57944561554793, OldestInputEvent=9223372036854775807, NewestInputEvent=0, HandleInputStart=57944572110669, AnimationStart=57944572173169, PerformTraversalsStart=57944572177207, DrawStart=57944572835400, SyncQueued=57944573096900, SyncStart=57944573152169, IssueDrawCommandsStart=57944573208938, SwapBuffers=57944581240861, FrameCompleted=57944583126054, DequeueBufferDuration=5544000, QueueBufferDuration=908000,
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
V/InputMethodManager(13508): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(13508): startInputInner - Id : 0
I/InputMethodManager(13508): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport(13508): Input channel constructed: fd=102
D/InputTransport(13508): Input channel destroyed: fd=100
D/ViewRootImpl@3185f49[MainActivity](13508): setWindowStopped(true) old=false
D/SurfaceView(13508): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792} of ViewRootImpl@3185f49[MainActivity]
D/SurfaceView(13508): show() Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@5f156f@1[13508])/@0xc7704c2 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792}
D/SurfaceView(13508): surfaceDestroyed callback.size 1 #1 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792}
W/libEGL  (13508): EGLNativeWindowType 0x787c14b010 disconnect failed
D/SurfaceView(13508): destroy() Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@5f156f@1[13508])/@0xc7704c2 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ........ 0,0-1440,2792}
D/ViewRootImpl@3185f49[MainActivity](13508): Surface release. android.view.WindowManagerGlobal.setStoppedState:669 android.app.Activity.performStop:7650 android.app.ActivityThread.callActivityOnStop:4402 android.app.ActivityThread.performStopActivityInner:4380 android.app.ActivityThread.handleStopActivity:4455 android.app.servertransaction.StopActivityItem.execute:41 android.app.servertransaction.TransactionExecutor.executeLifecycleState:145 android.app.servertransaction.TransactionExecutor.execute:70
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_WINDOW_FOCUS_CHANGED 1 0
D/ViewRootImpl@3185f49[MainActivity](13508): setWindowStopped(false) old=true
D/SurfaceView(13508): windowStopped(false) false io.flutter.embedding.android.FlutterSurfaceView{5f156f G.E...... ......I. 0,0-1440,2792} of ViewRootImpl@3185f49[MainActivity]
D/ViewRootImpl@3185f49[MainActivity](13508): setWindowStopped(false) old=false
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_RESIZED: frame=Rect(0, 0 - 1440, 2960) ci=Rect(0, 84 - 0, 1166) vi=Rect(0, 84 - 0, 1166) or=1
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_RESIZED: frame=Rect(0, 0 - 1440, 2960) ci=Rect(0, 84 - 0, 168) vi=Rect(0, 84 - 0, 168) or=1
I/Choreographer(13508): Skipped 143 frames!  The application may be doing too much work on its main thread.
D/SurfaceView(13508): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792} of ViewRootImpl@3185f49[MainActivity]
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x1 surface={valid=true 517478146048} changed=true
W/libEGL  (13508): EGLNativeWindowType 0x787bede010 disconnect failed
D/OpenGLRenderer(13508): eglDestroySurface = 0x787c21e580, 0x787bede000
D/mali_winsys(13508): EGLint new_window_surface(egl_winsys_display *, void *, EGLSurface, EGLConfig, egl_winsys_surface **, EGLBoolean) returns 0x3000
D/OpenGLRenderer(13508): eglCreateWindowSurface = 0x787c21e580, 0x787c19e010
D/SurfaceView(13508): show() Surface(name=SurfaceView - com.example.budget_buddy/com.example.budget_buddy.MainActivity@5f156f@2[13508])/@0x96c86e io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/SurfaceView(13508): surfaceCreated 1 #5 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/mali_winsys(13508): EGLint new_window_surface(egl_winsys_display *, void *, EGLSurface, EGLConfig, egl_winsys_surface **, EGLBoolean) returns 0x3000
D/SurfaceView(13508): surfaceChanged (1440,2792) 1 #5 io.flutter.embedding.android.FlutterSurfaceView{5f156f V.E...... ......ID 0,0-1440,2792}
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
V/InputMethodManager(13508): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(13508): startInputInner - Id : 0
I/InputMethodManager(13508): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport(13508): Input channel constructed: fd=100
D/InputTransport(13508): Input channel destroyed: fd=102
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x1 surface={valid=true 517478146048} changed=false
D/InputMethodManager(13508): SSI - flag : 0 Pid : 13508 view : com.example.budget_buddy
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
V/InputMethodManager(13508): Starting input: tba=com.example.budget_buddy ic=io.flutter.plugin.editing.InputConnectionAdaptor@21b7746 mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(13508): startInputInner - Id : 0
I/InputMethodManager(13508): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport(13508): Input channel constructed: fd=115
D/InputTransport(13508): Input channel destroyed: fd=100
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_RESIZED: frame=Rect(0, 0 - 1440, 2960) ci=Rect(0, 84 - 0, 1338) vi=Rect(0, 84 - 0, 1338) or=1
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x1 surface={valid=true 517478146048} changed=false
D/FlutterJNI(13508): Sending viewport metrics to the engine.
W/le.budget_budd(13508): Accessing hidden method Landroid/view/View;->getViewRootImpl()Landroid/view/ViewRootImpl; (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden field Landroid/view/View$AttachInfo;->mVisibleInsets:Landroid/graphics/Rect; (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden field Landroid/view/ViewRootImpl;->mAttachInfo:Landroid/view/View$AttachInfo; (light greylist, reflection)
W/le.budget_budd(13508): Accessing hidden field Landroid/graphics/Insets;->left:I (light greylist, linking)
W/le.budget_budd(13508): Accessing hidden field Landroid/graphics/Insets;->top:I (light greylist, linking)
W/le.budget_budd(13508): Accessing hidden field Landroid/graphics/Insets;->right:I (light greylist, linking)
W/le.budget_budd(13508): Accessing hidden field Landroid/graphics/Insets;->bottom:I (light greylist, linking)
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
V/InputMethodManager(13508): Starting input: tba=com.example.budget_buddy ic=io.flutter.plugin.editing.InputConnectionAdaptor@b2ed31b mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(13508): startInputInner - Id : 0
I/InputMethodManager(13508): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport(13508): Input channel constructed: fd=117
D/InputTransport(13508): Input channel destroyed: fd=115
D/InputMethodManager(13508): SSI - flag : 0 Pid : 13508 view : com.example.budget_buddy
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
W/IInputConnectionWrapper(13508): getExtractedText on inactive InputConnection
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_RESIZED: frame=Rect(0, 0 - 1440, 2960) ci=Rect(0, 84 - 0, 1166) vi=Rect(0, 84 - 0, 1166) or=1
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x1 surface={valid=true 517478146048} changed=false
D/FlutterJNI(13508): Sending viewport metrics to the engine.
D/InputMethodManager(13508): HSIFW - flag : 0 Pid : 13508
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_RESIZED: frame=Rect(0, 0 - 1440, 2960) ci=Rect(0, 84 - 0, 168) vi=Rect(0, 84 - 0, 168) or=1
D/ViewRootImpl@3185f49[MainActivity](13508): Relayout returned: old=[0,0][1440,2960] new=[0,0][1440,2960] result=0x1 surface={valid=true 517478146048} changed=false
D/FlutterJNI(13508): Sending viewport metrics to the engine.
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
D/ViewRootImpl@3185f49[MainActivity](13508): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
D/InputMethodManager(13508): prepareNavigationBarInfo() DecorView@3e57aa9[MainActivity]
D/InputMethodManager(13508): getNavigationBarColor() -16777216
V/InputMethodManager(13508): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager(13508): startInputInner - Id : 0
I/InputMethodManager(13508): startInputInner - mService.startInputOrWindowGainedFocus
D/InputTransport(13508): Input channel constructed: fd=118
D/InputTransport(13508): Input channel destroyed: fd=117

}}
[CONTEXT & CODE ERRORS END]
