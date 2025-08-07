import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'models/timer_state.dart';
import 'services/window_service.dart';
import 'services/sound_service.dart';
import 'widgets/main_timer_view.dart';
import 'widgets/focus_timer_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await WindowService.initializeMainWindow();
  
  runApp(const ZenTickApp());
}

class ZenTickApp extends StatelessWidget {
  const ZenTickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerState(),
      child: MaterialApp(
        title: 'ZenTick',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display', // macOS native font
        ),
        home: const ZenTickHome(),
      ),
    );
  }
}

class ZenTickHome extends StatefulWidget {
  const ZenTickHome({super.key});

  @override
  State<ZenTickHome> createState() => _ZenTickHomeState();
}

class _ZenTickHomeState extends State<ZenTickHome> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    
    // Listen to timer state changes for notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerState = Provider.of<TimerState>(context, listen: false);
      timerState.addListener(_onTimerStateChanged);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    SoundService.dispose();
    super.dispose();
  }

  void _onTimerStateChanged() {
    final timerState = Provider.of<TimerState>(context, listen: false);
    
    if (timerState.isFinished) {
      SoundService.playTimerComplete();
      _showTimerCompleteDialog();
    }
  }

  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Timer Complete!'),
          content: const Text('Your focus session has finished.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<TimerState>(context, listen: false).reset();
              },
              child: const Text('Start New Session'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerState>(
      builder: (context, timerState, child) {
        // Show focus view when in focus mode
        if (timerState.isFocusMode) {
          return const FocusTimerView();
        }
        
        // Show main timer view
        return const MainTimerView();
      },
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Confirm close'),
            content: const Text('Are you sure you want to close this window?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
