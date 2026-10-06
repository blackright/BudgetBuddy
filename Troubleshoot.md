You are an expert software engineering agent and a master of system debugging. Your goal is to analyze code errors, identify the root cause, design a clean solution adhering to programming best practices, and draft a structured implementation plan. 

CRITICAL PROTOCOL: You must STOP and wait for explicit user approval after presenting your analysis and implementation plan. Do not write or execute the final code implementation until the user explicitly says "Approved" or "Proceed".

Follow this exact structure for your response:

### 🔍 1. Error Diagnosis & Root Cause Analysis
* **What Happened:** A clear, plain-English explanation of the error.
* **Why It Happened:** A deep technical breakdown of the root cause (e.g., race conditions, null pointers, state mismatches, incorrect API usage).

### 🛠️ 2. The Solution Strategy
* **The Best Practice Approach:** Explain the optimal, production-ready way to fix this issue according to real-world software engineering best practices. 
* **Alternative Approaches Considered:** (Briefly state why other quick-fixes were rejected in favor of the best practice approach).

### 📋 3. Step-by-Step Implementation Plan
Break down exactly what needs to change in the codebase to implement the solution. Use bullet points to list:
* Files that need modification or creation.
* Specific architectural, logic, or syntax changes required.
* Post-fix validation steps (e.g., what unit tests or manual checks to run).

### 🛑 AWAITING APPROVAL
Review the diagnosis and plan above. Please reply with "Approved" or provide feedback to modify the approach. I am standing by for your authorization before writing or applying the code changes.

***
[CONTEXT & CODE ERRORS START]
{{PS C:\dev\MobileDev\BudgetBuddy> flutter run
Launching lib\main.dart on SM G965F in debug mode...
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by net.rubygrapefruit.platform.internal.NativeLibraryLoader in an unnamed module (file:/C:/Users/Admin/.gradle/wrapper/dists/gradle-9.3.1-all/9ot9r568e8zfvvd4mn8rbu1j0/gradle-9.3.1/lib/native-platform-0.22-milestone-29.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled

WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): device_calendar
Future versions of Flutter will fail to build if your app uses plugins that apply KGP.

Please check the changelogs of these plugins and upgrade to a version that supports Built-in Kotlin.
If no such version exists, report the issue to the plugin. If necessary, here is a guide on filing
an issue against a plugin: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers#report-incompatible-kotlin-gradle-plugin-usage-to-plugin-authors

If you are a plugin author, please migrate your plugin to Built-in Kotlin using this guide: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors
Running Gradle task 'assembleDebug'...                             44.7s
✓ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...          50.7s
I/FlutterActivityAndFragmentDelegate( 5926): If you are attempting to set --enable-dart-profiling via Intent extras to launch a Flutter component outside of using the Flutter CLI, note that support for setting engine flags on Android via Intent will soon be dropped; see https://github.com/flutter/flutter/issues/180686 for more information on this breaking change. To migrate, set --enable-dart-profiling or any other flags specified via Intent extras on the command line instead or see https://github.com/flutter/flutter/blob/main/docs/engine/Flutter-Android-Engine-Flags.md for alternative methods.
D/FlutterJNI( 5926): Beginning load of flutter...
D/FlutterJNI( 5926): flutter (null) was loaded normally!
I/flutter ( 5926): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
D/FlutterRenderer( 5926): Width is zero. 0,0
I/flutter ( 5926): ╔══════════════════════════════════════════════════════╗
I/flutter ( 5926): ║                 ISAR CONNECT STARTED                 ║
I/flutter ( 5926): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5926): ║         Open the link to connect to the Isar         ║
I/flutter ( 5926): ║        Inspector while this build is running.        ║
I/flutter ( 5926): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5926): ║ https://inspect.isar.dev/3.1.0+1/#/34687/1P3KT4SiUBU ║
I/flutter ( 5926): ╚══════════════════════════════════════════════════════╝
D/FlutterRenderer( 5926): Width is zero. 0,0
D/FlutterJNI( 5926): Sending viewport metrics to the engine.
I/SurfaceView( 5926): surfaceChanged (1440,2792) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{62e2602 V.E...... ......ID 0,0-1440,2792}
I/mali_egl( 5926): eglDestroySurface() in
I/mali_winsys( 5926): delete_surface() [1440x2792] return
I/mali_egl( 5926): eglDestroySurface() out
W/libEGL  ( 5926): EGLNativeWindowType 0x760607a010 disconnect failed
I/mali_winsys( 5926): new_window_surface() [1440x2792] return: 0x3000
I/Choreographer( 5926): Skipped 83 frames!  The application may be doing too much work on its main thread.
I/ViewRootImpl@7f4061c[MainActivity]( 5926): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=8 res=0x3 s={true 509507420160} ch=false
I/ViewRootImpl@7f4061c[MainActivity]( 5926): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 5926): prepareNavigationBarInfo() DecorView@feaaea2[MainActivity]
D/InputMethodManager( 5926): getNavigationBarColor() -855310
D/InputMethodManager( 5926): prepareNavigationBarInfo() DecorView@feaaea2[MainActivity]
D/InputMethodManager( 5926): getNavigationBarColor() -855310
V/InputMethodManager( 5926): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -855310 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 5926): startInputInner - Id : 0
I/InputMethodManager( 5926): startInputInner - mService.startInputOrWindowGainedFocus
I/ViewRootImpl@7f4061c[MainActivity]( 5926): MSG_RESIZED_REPORT: frame=(0,0,1440,2960) ci=(0,84,0,168) vi=(0,84,0,168) or=1
D/InputMethodManager( 5926): prepareNavigationBarInfo() DecorView@feaaea2[MainActivity]
D/InputMethodManager( 5926): getNavigationBarColor() -855310
V/InputMethodManager( 5926): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -855310 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 5926): startInputInner - Id : 0
D/FlutterJNI( 5926): Sending viewport metrics to the engine.
Syncing files to device SM G965F...                                394ms

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on SM G965F is available at: http://127.0.0.1:64913/4dh8gk97Kro=/
The Flutter DevTools debugger and profiler on SM G965F is available at:
http://127.0.0.1:64913/4dh8gk97Kro=/devtools/?uri=ws://127.0.0.1:64913/4dh8gk97Kro=
/ws
W/Gralloc3( 5926): mapper 3.x is not supported
I/gralloc ( 5926): Arm Module v1.0
I/Choreographer( 5926): Skipped 177 frames!  The application may be doing too much work on its main thread.
D/PhoneWindow( 5926): forceLight changed to false [com.example.budget_buddy/com.example.budget_buddy.MainActivity] from com.android.internal.policy.PhoneWindow.updateForceLightNavigationBar:4280 com.android.internal.policy.PhoneWindow.setNavigationBarColor:4102 io.flutter.plugin.platform.PlatformPlugin.setSystemChromeSystemUIOverlayStyle:578 io.flutter.plugin.platform.PlatformPlugin.access$700:37 io.flutter.plugin.platform.PlatformPlugin$1.setSystemUiOverlayStyle:125
I/ViewRootImpl@7f4061c[MainActivity]( 5926): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=6 res=0x3 s={true 509507420160} ch=false
D/FlutterJNI( 5926): Sending viewport metrics to the engine.
I/OpenGLRenderer( 5926): doUpdatePositionAsync is called and callVoidMethod
D/ProfileInstaller( 5926): Installing profile for com.example.budget_buddy

══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY
╞═══════════════════════════════════════════════════════════
The following assertion was thrown building LayoutBuilder:
BoxConstraints has non-normalized height constraints.
The offending constraints were:
  BoxConstraints(0.0<=w<=Infinity, 216.0<=h<=201.6; NOT NORMALIZED)

The relevant error-causing widget was:
  Navigator-[LabeledGlobalKey<NavigatorState>#a360a]
  Navigator:file:///C:/Users/Admin/AppData/Local/Pub/Cache/hosted/pub.dev/go_router
  -18.0.2/lib/src/builder.dart:461:23

When the exception was thrown, this was the stack:
#0      BoxConstraints.debugAssertIsValid.<anonymous closure>.throwError
(package:flutter/src/rendering/box.dart:549:9)
#1      BoxConstraints.debugAssertIsValid.<anonymous closure>
(package:flutter/src/rendering/box.dart:604:9)
#2      BoxConstraints.debugAssertIsValid
(package:flutter/src/rendering/box.dart:619:6)
#3      new AnimatedContainer
(package:flutter/src/widgets/implicit_animations.dart:627:50)
#4      _TimePickerDialogState.build.<anonymous closure>
(package:flutter/src/material/time_picker.dart:2694:24)
#5      _LayoutBuilderElement._rebuildWithConstraints.updateChildCallback
(package:flutter/src/widgets/layout_builder.dart:232:74)
#6      BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3114:19)
#7      _LayoutBuilderElement._rebuildWithConstraints
(package:flutter/src/widgets/layout_builder.dart:270:12)
#8      RenderAbstractLayoutBuilderMixin.layoutCallback
(package:flutter/src/widgets/layout_builder.dart:333:38)
#9      RenderObjectWithLayoutCallbackMixin.runLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:4313:33)
#10     RenderObject.invokeLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:3042:17)
#11     PipelineOwner._enableMutationsToDirtySubtrees
(package:flutter/src/rendering/object.dart:1223:15)
#12     RenderObject.invokeLayoutCallback
(package:flutter/src/rendering/object.dart:3041:14)
#13     RenderObjectWithLayoutCallbackMixin.runLayoutCallback
(package:flutter/src/rendering/object.dart:4313:5)
#14     _RenderLayoutBuilder.performLayout
(package:flutter/src/widgets/layout_builder.dart:447:5)
#15     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#16     RenderPadding.performLayout
(package:flutter/src/rendering/shifted_box.dart:262:12)
#17     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#18     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#19     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#20     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#21     RenderCustomPaint.performLayout
(package:flutter/src/rendering/custom_paint.dart:574:11)
#22     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#23     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#24     _RenderCustomClip.performLayout
(package:flutter/src/rendering/proxy_box.dart:1549:11)
#25     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#26     RenderConstrainedBox.performLayout
(package:flutter/src/rendering/proxy_box.dart:296:14)
#27     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#28     RenderPositionedBox.performLayout
(package:flutter/src/rendering/shifted_box.dart:484:14)
#29     RenderObject._layoutWithoutResize
(package:flutter/src/rendering/object.dart:2771:7)
#30     PipelineOwner.flushLayout
(package:flutter/src/rendering/object.dart:1174:18)
#31     PipelineOwner.flushLayout
(package:flutter/src/rendering/object.dart:1187:15)
#32     RendererBinding.drawFrame
(package:flutter/src/rendering/binding.dart:692:23)
#33     WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1573:13)
#34     RendererBinding._handlePersistentFrameCallback
(package:flutter/src/rendering/binding.dart:558:5)
#35     SchedulerBinding._invokeFrameCallback
(package:flutter/src/scheduler/binding.dart:1430:15)
#36     SchedulerBinding.handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1345:9)
#37     SchedulerBinding._handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1198:5)
#38     _invoke (dart:ui/hooks.dart:441:13)
#39     PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:450:5)
#40     _drawFrame (dart:ui/hooks.dart:413:31)

═══════════════════════════════════════════════════════════════════════════════════
═════════════════

Another exception was thrown: BoxConstraints has non-normalized height constraints.
I/ViewRootImpl@7f4061c[MainActivity]( 5926): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputMethodManager( 5926): prepareNavigationBarInfo() DecorView@feaaea2[MainActivity]
D/InputMethodManager( 5926): getNavigationBarColor() -16777216
D/InputTransport( 5926): Input channel destroyed: 'ClientS', fd=95
I/ViewRootImpl@7f4061c[MainActivity]( 5926): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager( 5926): prepareNavigationBarInfo() DecorView@feaaea2[MainActivity]
D/InputMethodManager( 5926): getNavigationBarColor() -16777216
D/InputMethodManager( 5926): prepareNavigationBarInfo() DecorView@feaaea2[MainActivity]
D/InputMethodManager( 5926): getNavigationBarColor() -16777216
V/InputMethodManager( 5926): Starting input: tba=com.example.budget_buddy ic=null mNaviBarColor -16777216 mIsGetNaviBarColorSuccess true , NavVisible : true , NavTrans : false
D/InputMethodManager( 5926): startInputInner - Id : 0
I/InputMethodManager( 5926): startInputInner - mService.startInputOrWindowGainedFocus


══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY
╞═══════════════════════════════════════════════════════════
The following assertion was thrown building LayoutBuilder:
BoxConstraints has non-normalized height constraints.
The offending constraints were:
  BoxConstraints(0.0<=w<=Infinity, 216.0<=h<=201.6; NOT NORMALIZED)

The relevant error-causing widget was:
  Navigator-[LabeledGlobalKey<NavigatorState>#a360a]
  Navigator:file:///C:/Users/Admin/AppData/Local/Pub/Cache/hosted/pub.dev/go_router
  -18.0.2/lib/src/builder.dart:461:23

When the exception was thrown, this was the stack:
#0      BoxConstraints.debugAssertIsValid.<anonymous closure>.throwError
(package:flutter/src/rendering/box.dart:549:9)
#1      BoxConstraints.debugAssertIsValid.<anonymous closure>
(package:flutter/src/rendering/box.dart:604:9)
#2      BoxConstraints.debugAssertIsValid
(package:flutter/src/rendering/box.dart:619:6)
#3      new AnimatedContainer
(package:flutter/src/widgets/implicit_animations.dart:627:50)
#4      _TimePickerDialogState.build.<anonymous closure>
(package:flutter/src/material/time_picker.dart:2694:24)
#5      _LayoutBuilderElement._rebuildWithConstraints.updateChildCallback
(package:flutter/src/widgets/layout_builder.dart:232:74)
#6      BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3114:19)
#7      _LayoutBuilderElement._rebuildWithConstraints
(package:flutter/src/widgets/layout_builder.dart:270:12)
#8      RenderAbstractLayoutBuilderMixin.layoutCallback
(package:flutter/src/widgets/layout_builder.dart:333:38)
#9      RenderObjectWithLayoutCallbackMixin.runLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:4313:33)
#10     RenderObject.invokeLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:3042:17)
#11     PipelineOwner._enableMutationsToDirtySubtrees
(package:flutter/src/rendering/object.dart:1223:15)
#12     RenderObject.invokeLayoutCallback
(package:flutter/src/rendering/object.dart:3041:14)
#13     RenderObjectWithLayoutCallbackMixin.runLayoutCallback
(package:flutter/src/rendering/object.dart:4313:5)
#14     _RenderLayoutBuilder.performLayout
(package:flutter/src/widgets/layout_builder.dart:447:5)
#15     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#16     RenderPadding.performLayout
(package:flutter/src/rendering/shifted_box.dart:262:12)
#17     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#18     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#19     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#20     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#21     RenderCustomPaint.performLayout
(package:flutter/src/rendering/custom_paint.dart:574:11)
#22     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#23     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#24     _RenderCustomClip.performLayout
(package:flutter/src/rendering/proxy_box.dart:1549:11)
#25     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#26     RenderConstrainedBox.performLayout
(package:flutter/src/rendering/proxy_box.dart:296:14)
#27     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#28     RenderPositionedBox.performLayout
(package:flutter/src/rendering/shifted_box.dart:484:14)
#29     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#30     RenderPadding.performLayout
(package:flutter/src/rendering/shifted_box.dart:262:12)
#31     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#32     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#33     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#34     RenderPadding.performLayout
(package:flutter/src/rendering/shifted_box.dart:262:12)
#35     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#36     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#37     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#38     RenderPadding.performLayout
(package:flutter/src/rendering/shifted_box.dart:262:12)
#39     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#40     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#41     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#42     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#43     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#44     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#45     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#46     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#47     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#48     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#49     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#50     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#51     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#52     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#53     RenderOffstage.performLayout
(package:flutter/src/rendering/proxy_box.dart:3923:13)
#54     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#55     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#56     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#57     _RenderTheaterMixin.layoutChild
(package:flutter/src/widgets/overlay.dart:1124:13)
#58     _RenderTheater.performLayout
(package:flutter/src/widgets/overlay.dart:1482:9)
#59     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#60     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#61     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#62     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#63     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#64     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#65     RenderCustomPaint.performLayout
(package:flutter/src/rendering/custom_paint.dart:574:11)
#66     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#67     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#68     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#69     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#70     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#71     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#72     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#73     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#74     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#75     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#76     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#77     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#78     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#79     RenderView.performLayout (package:flutter/src/rendering/view.dart:292:12)
#80     RenderObject._layoutWithoutResize
(package:flutter/src/rendering/object.dart:2771:7)
#81     PipelineOwner.flushLayout
(package:flutter/src/rendering/object.dart:1174:18)
#82     PipelineOwner.flushLayout
(package:flutter/src/rendering/object.dart:1187:15)
#83     RendererBinding.drawFrame
(package:flutter/src/rendering/binding.dart:692:23)
#84     WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1573:13)
#85     RendererBinding._handlePersistentFrameCallback
(package:flutter/src/rendering/binding.dart:558:5)
#86     SchedulerBinding._invokeFrameCallback
(package:flutter/src/scheduler/binding.dart:1430:15)
#87     SchedulerBinding.handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1345:9)
#88     SchedulerBinding.scheduleWarmUpFrame.<anonymous closure>
(package:flutter/src/scheduler/binding.dart:1055:9)
#89     PlatformDispatcher.scheduleWarmUpFrame.<anonymous closure>
(dart:ui/platform_dispatcher.dart:912:16)
#93     _RawReceivePort._handleMessage
(dart:isolate-patch/isolate_patch.dart:192:12)
(elided 3 frames from class _Timer and dart:async-patch)

═══════════════════════════════════════════════════════════════════════════════════
═════════════════

Performing hot reload...
Reloaded 1 of 2368 libraries in 2,980ms (compile: 81 ms, reload: 935 ms,
reassemble: 1406 ms).
I/ViewRootImpl@7f4061c[MainActivity]( 5926): ViewPostIme key 0
I/ViewRootImpl@7f4061c[MainActivity]( 5926): ViewPostIme key 1
Another exception was thrown: BoxConstraints has non-normalized height constraints.
I/ViewRootImpl@7f4061c[MainActivity]( 5926): ViewPostIme key 0
I/ViewRootImpl@7f4061c[MainActivity]( 5926): ViewPostIme key 1
I/ViewRootImpl@7f4061c[MainActivity]( 5926): ViewPostIme key 0
I/ViewRootImpl@7f4061c[MainActivity]( 5926): ViewPostIme key 1
Another exception was thrown: BoxConstraints has non-normalized height constraints.
I/ViewRootImpl@7f4061c[MainActivity]( 5926): ViewPostIme key 0
I/ViewRootImpl@7f4061c[MainActivity]( 5926): ViewPostIme key 1

Performing hot restart...
Restarted application in 6,691ms.
I/flutter ( 5926): ╔══════════════════════════════════════════════════════╗
I/flutter ( 5926): ║                 ISAR CONNECT STARTED                 ║
I/flutter ( 5926): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5926): ║         Open the link to connect to the Isar         ║
I/flutter ( 5926): ║        Inspector while this build is running.        ║
I/flutter ( 5926): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5926): ║ https://inspect.isar.dev/3.1.0+1/#/64913/4dh8gk97Kro ║
I/flutter ( 5926): ╚══════════════════════════════════════════════════════╝
I/ViewRootImpl@7f4061c[MainActivity]( 5926): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=5 res=0x1 s={true 509507420160} ch=false

══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY
╞═══════════════════════════════════════════════════════════
The following assertion was thrown building LayoutBuilder:
BoxConstraints has non-normalized height constraints.
The offending constraints were:
  BoxConstraints(0.0<=w<=Infinity, 216.0<=h<=201.6; NOT NORMALIZED)

The relevant error-causing widget was:
  Center
  Center:file:///C:/dev/MobileDev/BudgetBuddy/lib/features/medical/presentation/rem
  inder_picker_sheet.dart:174:36

When the exception was thrown, this was the stack:
#0      BoxConstraints.debugAssertIsValid.<anonymous closure>.throwError
(package:flutter/src/rendering/box.dart:549:9)
#1      BoxConstraints.debugAssertIsValid.<anonymous closure>
(package:flutter/src/rendering/box.dart:604:9)
#2      BoxConstraints.debugAssertIsValid
(package:flutter/src/rendering/box.dart:619:6)
#3      new AnimatedContainer
(package:flutter/src/widgets/implicit_animations.dart:627:50)
#4      _TimePickerDialogState.build.<anonymous closure>
(package:flutter/src/material/time_picker.dart:2694:24)
#5      _LayoutBuilderElement._rebuildWithConstraints.updateChildCallback
(package:flutter/src/widgets/layout_builder.dart:232:74)
#6      BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3114:19)
#7      _LayoutBuilderElement._rebuildWithConstraints
(package:flutter/src/widgets/layout_builder.dart:270:12)
#8      RenderAbstractLayoutBuilderMixin.layoutCallback
(package:flutter/src/widgets/layout_builder.dart:333:38)
#9      RenderObjectWithLayoutCallbackMixin.runLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:4313:33)
#10     RenderObject.invokeLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:3042:17)
#11     PipelineOwner._enableMutationsToDirtySubtrees
(package:flutter/src/rendering/object.dart:1223:15)
#12     RenderObject.invokeLayoutCallback
(package:flutter/src/rendering/object.dart:3041:14)
#13     RenderObjectWithLayoutCallbackMixin.runLayoutCallback
(package:flutter/src/rendering/object.dart:4313:5)
#14     _RenderLayoutBuilder.performLayout
(package:flutter/src/widgets/layout_builder.dart:447:5)
#15     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#16     RenderPadding.performLayout
(package:flutter/src/rendering/shifted_box.dart:262:12)
#17     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#18     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#19     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#20     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#21     RenderCustomPaint.performLayout
(package:flutter/src/rendering/custom_paint.dart:574:11)
#22     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#23     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#24     _RenderCustomClip.performLayout
(package:flutter/src/rendering/proxy_box.dart:1549:11)
#25     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#26     RenderConstrainedBox.performLayout
(package:flutter/src/rendering/proxy_box.dart:296:14)
#27     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#28     RenderPositionedBox.performLayout
(package:flutter/src/rendering/shifted_box.dart:484:14)
#29     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#30     RenderPadding.performLayout
(package:flutter/src/rendering/shifted_box.dart:262:12)
#31     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#32     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#33     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#34     RenderPositionedBox.performLayout
(package:flutter/src/rendering/shifted_box.dart:484:14)
#35     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#36     RenderConstrainedBox.performLayout
(package:flutter/src/rendering/proxy_box.dart:296:14)
#37     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#38     _RenderSingleChildViewport.performLayout
(package:flutter/src/widgets/single_child_scroll_view.dart:502:14)
#39     RenderObject._layoutWithoutResize
(package:flutter/src/rendering/object.dart:2771:7)
#40     PipelineOwner.flushLayout
(package:flutter/src/rendering/object.dart:1174:18)
#41     PipelineOwner.flushLayout
(package:flutter/src/rendering/object.dart:1187:15)
#42     RendererBinding.drawFrame
(package:flutter/src/rendering/binding.dart:692:23)
#43     WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1573:13)
#44     RendererBinding._handlePersistentFrameCallback
(package:flutter/src/rendering/binding.dart:558:5)
#45     SchedulerBinding._invokeFrameCallback
(package:flutter/src/scheduler/binding.dart:1430:15)
#46     SchedulerBinding.handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1345:9)
#47     SchedulerBinding._handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1198:5)
#48     _invoke (dart:ui/hooks.dart:441:13)
#49     PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:450:5)
#50     _drawFrame (dart:ui/hooks.dart:413:31)

═══════════════════════════════════════════════════════════════════════════════════
═════════════════


Performing hot restart...
Restarted application in 6,692ms.
I/flutter ( 5926): ╔══════════════════════════════════════════════════════╗
I/flutter ( 5926): ║                 ISAR CONNECT STARTED                 ║
I/flutter ( 5926): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5926): ║         Open the link to connect to the Isar         ║
I/flutter ( 5926): ║        Inspector while this build is running.        ║
I/flutter ( 5926): ╟──────────────────────────────────────────────────────╢
I/flutter ( 5926): ║ https://inspect.isar.dev/3.1.0+1/#/64913/4dh8gk97Kro ║
I/flutter ( 5926): ╚══════════════════════════════════════════════════════╝
I/ViewRootImpl@7f4061c[MainActivity]( 5926): Relayout returned: old=(0,0,1440,2960) new=(0,0,1440,2960) req=(1440,2960)0 dur=6 res=0x1 s={true 509507420160} ch=false

══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY
╞═══════════════════════════════════════════════════════════
The following assertion was thrown building LayoutBuilder:
BoxConstraints has non-normalized height constraints.
The offending constraints were:
  BoxConstraints(0.0<=w<=Infinity, 216.0<=h<=201.6; NOT NORMALIZED)

The relevant error-causing widget was:
  MediaQuery
  MediaQuery:file:///C:/dev/MobileDev/BudgetBuddy/lib/features/medical/presentation
  /reminder_picker_sheet.dart:167:28

When the exception was thrown, this was the stack:
#0      BoxConstraints.debugAssertIsValid.<anonymous closure>.throwError
(package:flutter/src/rendering/box.dart:549:9)
#1      BoxConstraints.debugAssertIsValid.<anonymous closure>
(package:flutter/src/rendering/box.dart:604:9)
#2      BoxConstraints.debugAssertIsValid
(package:flutter/src/rendering/box.dart:619:6)
#3      new AnimatedContainer
(package:flutter/src/widgets/implicit_animations.dart:627:50)
#4      _TimePickerDialogState.build.<anonymous closure>
(package:flutter/src/material/time_picker.dart:2694:24)
#5      _LayoutBuilderElement._rebuildWithConstraints.updateChildCallback
(package:flutter/src/widgets/layout_builder.dart:232:74)
#6      BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3114:19)
#7      _LayoutBuilderElement._rebuildWithConstraints
(package:flutter/src/widgets/layout_builder.dart:270:12)
#8      RenderAbstractLayoutBuilderMixin.layoutCallback
(package:flutter/src/widgets/layout_builder.dart:333:38)
#9      RenderObjectWithLayoutCallbackMixin.runLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:4313:33)
#10     RenderObject.invokeLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:3042:17)
#11     PipelineOwner._enableMutationsToDirtySubtrees
(package:flutter/src/rendering/object.dart:1223:15)
#12     RenderObject.invokeLayoutCallback
(package:flutter/src/rendering/object.dart:3041:14)
#13     RenderObjectWithLayoutCallbackMixin.runLayoutCallback
(package:flutter/src/rendering/object.dart:4313:5)
#14     _RenderLayoutBuilder.performLayout
(package:flutter/src/widgets/layout_builder.dart:447:5)
#15     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#16     RenderPadding.performLayout
(package:flutter/src/rendering/shifted_box.dart:262:12)
#17     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#18     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#19     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#20     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#21     RenderCustomPaint.performLayout
(package:flutter/src/rendering/custom_paint.dart:574:11)
#22     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#23     RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#24     _RenderCustomClip.performLayout
(package:flutter/src/rendering/proxy_box.dart:1549:11)
#25     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#26     RenderConstrainedBox.performLayout
(package:flutter/src/rendering/proxy_box.dart:296:14)
#27     RenderObject.layout (package:flutter/src/rendering/object.dart:2923:7)
#28     RenderPositionedBox.performLayout
(package:flutter/src/rendering/shifted_box.dart:484:14)
#29     RenderObject._layoutWithoutResize
(package:flutter/src/rendering/object.dart:2771:7)
#30     PipelineOwner.flushLayout
(package:flutter/src/rendering/object.dart:1174:18)
#31     PipelineOwner.flushLayout
(package:flutter/src/rendering/object.dart:1187:15)
#32     RendererBinding.drawFrame
(package:flutter/src/rendering/binding.dart:692:23)
#33     WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1573:13)
#34     RendererBinding._handlePersistentFrameCallback
(package:flutter/src/rendering/binding.dart:558:5)
#35     SchedulerBinding._invokeFrameCallback
(package:flutter/src/scheduler/binding.dart:1430:15)
#36     SchedulerBinding.handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1345:9)
#37     SchedulerBinding._handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1198:5)
#38     _invoke (dart:ui/hooks.dart:441:13)
#39     PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:450:5)
#40     _drawFrame (dart:ui/hooks.dart:413:31)

═══════════════════════════════════════════════════════════════════════════════════
═════════════════

Another exception was thrown: BoxConstraints has non-normalized height constraints.}}
[CONTEXT & CODE ERRORS END]
