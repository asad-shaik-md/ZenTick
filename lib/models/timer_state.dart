import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/window_service.dart';

enum TimerStatus { initial, running, paused, finished }
enum StopwatchStatus { initial, running, paused }

class TimerState extends ChangeNotifier {
  static const int defaultDuration = 25 * 60; // 25 minutes in seconds
  
  int _duration = defaultDuration;
  int _remainingTime = defaultDuration;
  TimerStatus _status = TimerStatus.initial;
  Timer? _timer;
  bool _isFocusMode = false;
  
  // Stopwatch properties
  int _stopwatchTime = 0; // elapsed time in seconds
  StopwatchStatus _stopwatchStatus = StopwatchStatus.initial;
  Timer? _stopwatchTimer;

  // Getters
  int get duration => _duration;
  int get remainingTime => _remainingTime;
  TimerStatus get status => _status;
  bool get isFocusMode => _isFocusMode;
  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isFinished => _status == TimerStatus.finished;
  bool get canStart => _status == TimerStatus.initial || _status == TimerStatus.paused;
  bool get canFocus => _status == TimerStatus.running;
  
  // Stopwatch getters
  int get stopwatchTime => _stopwatchTime;
  StopwatchStatus get stopwatchStatus => _stopwatchStatus;
  bool get isStopwatchRunning => _stopwatchStatus == StopwatchStatus.running;
  bool get isStopwatchPaused => _stopwatchStatus == StopwatchStatus.paused;

  // Formatted time display
  String get formattedTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Stopwatch formatted time display
  String get stopwatchFormattedTime {
    final minutes = _stopwatchTime ~/ 60;
    final seconds = _stopwatchTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Progress percentage (0.0 to 1.0)
  double get progress {
    if (_duration == 0) return 0.0;
    return 1.0 - (_remainingTime / _duration);
  }

  void setDuration(int minutes) {
    if (_status == TimerStatus.initial) {
      _duration = minutes * 60;
      _remainingTime = _duration;
      notifyListeners();
    }
  }

  void setCustomDuration(int totalSeconds) {
    if (_status == TimerStatus.initial) {
      _duration = totalSeconds;
      _remainingTime = _duration;
      notifyListeners();
    }
  }

  void start() {
    if (_status == TimerStatus.initial || _status == TimerStatus.paused) {
      _status = TimerStatus.running;
      _startTimer();
      notifyListeners();
    }
  }

  void pause() {
    if (_status == TimerStatus.running) {
      _status = TimerStatus.paused;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void reset() {
    _timer?.cancel();
    _status = TimerStatus.initial;
    _remainingTime = _duration;
    _isFocusMode = false;
    notifyListeners();
  }

  void toggleFocusMode() {
    if (_status == TimerStatus.running || _stopwatchStatus == StopwatchStatus.running) {
      _isFocusMode = !_isFocusMode;
      notifyListeners();
    }
  }

  // Stopwatch methods
  void startStopwatch() {
    if (_stopwatchStatus == StopwatchStatus.initial || _stopwatchStatus == StopwatchStatus.paused) {
      _stopwatchStatus = StopwatchStatus.running;
      _startStopwatchTimer();
      notifyListeners();
    }
  }

  void pauseStopwatch() {
    if (_stopwatchStatus == StopwatchStatus.running) {
      _stopwatchStatus = StopwatchStatus.paused;
      _stopwatchTimer?.cancel();
      notifyListeners();
    }
  }

  void resetStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchStatus = StopwatchStatus.initial;
    _stopwatchTime = 0;
    _isFocusMode = false;
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _finish();
      }
    });
  }

  void _startStopwatchTimer() {
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _stopwatchTime++;
      notifyListeners();
    });
  }

  void _finish() async {
    _timer?.cancel();
    _status = TimerStatus.finished;
    
    // Exit focus mode if we're in it
    if (_isFocusMode) {
      _isFocusMode = false;
      await WindowService.exitFocusMode();
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatchTimer?.cancel();
    super.dispose();
  }
}
