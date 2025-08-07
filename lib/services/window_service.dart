import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  static const Size mainWindowSize = Size(400, 500);
  static const Size focusWindowSize = Size(240, 120);
  static const Offset focusWindowOffset = Offset(50, 50); // Bottom-left positioning

  static Future<void> initializeMainWindow() async {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: mainWindowSize,
      minimumSize: Size(350, 400),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setTitle('ZenTick');
    });
  }

  static Future<void> hideMainWindow() async {
    await windowManager.hide();
  }

  static Future<void> showMainWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  static Future<void> createFocusWindow() async {
    // Note: Flutter doesn't natively support multiple windows.
    // For a production app, you'd need to use platform channels
    // or a plugin that supports multiple windows.
    // For now, we'll simulate this by minimizing the main window
    // and creating a minimal overlay within the same window.
    await windowManager.minimize();
  }

  static Future<void> setupFocusMode() async {
    // Configure window for focus mode
    await windowManager.setSize(focusWindowSize);
    await windowManager.setPosition(focusWindowOffset);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSkipTaskbar(true);
    await windowManager.setResizable(false);
  }

  static Future<void> exitFocusMode() async {
    // Restore normal window settings
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setResizable(true);
    await windowManager.setSize(mainWindowSize);
    await windowManager.center();
    await windowManager.show();
  }

  static Future<void> positionFocusWindow() async {
    // Position the focus window in bottom-left corner
    await windowManager.setPosition(focusWindowOffset);
  }
}
