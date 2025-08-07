import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_state.dart';
import '../services/window_service.dart';

class MainTimerView extends StatefulWidget {
  const MainTimerView({super.key});

  @override
  State<MainTimerView> createState() => _MainTimerViewState();
}

class _MainTimerViewState extends State<MainTimerView> with SingleTickerProviderStateMixin {
  bool _isEditingTime = false;
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  final FocusNode _minutesFocus = FocusNode();
  final FocusNode _secondsFocus = FocusNode();
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _minutesFocus.dispose();
    _secondsFocus.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TimerState>(
        builder: (context, timerState, child) {
          // Handle tab switching when exiting focus mode
          if (timerState.shouldReturnToStopwatchTab && !timerState.isFocusMode) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_tabController.index != 1) {
                _tabController.animateTo(1); // Switch to stopwatch tab
              }
              timerState.clearTabReturnFlag();
            });
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height > 64 
                    ? MediaQuery.of(context).size.height - 64 
                    : 400,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Title
                  const Text(
                    'ZenTick',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.black87,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Tab Bar
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      tabs: const [
                        Tab(text: 'Timer'),
                        Tab(text: 'Stopwatch'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Tab View Content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Timer Tab
                        _buildTimerTab(timerState),
                        // Stopwatch Tab
                        _buildStopwatchTab(timerState),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerTab(TimerState timerState) {
    return Column(
      children: [
        // Timer Display
        _buildTimerDisplay(timerState),
        const SizedBox(height: 30),
        
        // Progress Bar
        _buildProgressBar(timerState),
        const SizedBox(height: 40),
        
        // Control Buttons
        _buildControlButtons(context, timerState),
        
        // Focus Button (only when running)
        if (timerState.canFocus) ...[
          const SizedBox(height: 20),
          _buildFocusButton(context, timerState),
        ],
      ],
    );
  }

  Widget _buildStopwatchTab(TimerState timerState) {
    return Column(
      children: [
        // Stopwatch Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            timerState.stopwatchFormattedTime,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w200,
              color: Colors.black87,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Stopwatch Control Buttons
        _buildStopwatchButtons(context, timerState),
        
        // Focus Button (only when running)
        if (timerState.isStopwatchRunning) ...[
          const SizedBox(height: 20),
          _buildStopwatchFocusButton(context, timerState),
        ],
      ],
    );
  }

  Widget _buildTimerDisplay(TimerState timerState) {
    if (timerState.status == TimerStatus.initial) {
      // Editable timer display when not running
      return GestureDetector(
        onTap: () => _startEditing(timerState),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: _isEditingTime ? Colors.orange.withValues(alpha: 0.6) : Colors.blue.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              if (_isEditingTime) ...[
                // Inline editing mode
                SizedBox(
                  width: 200, // Constrain the width
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minutes input
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _minutesController,
                          focusNode: _minutesFocus,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w200,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '00',
                          ),
                          onSubmitted: (_) => _secondsFocus.requestFocus(),
                        ),
                      ),
                      const Text(
                        ':',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w200,
                          color: Colors.black87,
                        ),
                      ),
                      // Seconds input
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _secondsController,
                          focusNode: _secondsFocus,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w200,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '00',
                          ),
                          onSubmitted: (_) => _finishEditing(timerState),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 32,
                      child: TextButton(
                        onPressed: () => _cancelEditing(timerState),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _finishEditing(timerState),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Set',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Regular display mode
                Text(
                  timerState.formattedTime,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w200,
                    color: Colors.black87,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to edit time',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      // Regular timer display when running/paused
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          timerState.formattedTime,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w200,
            color: Colors.black87,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      );
    }
  }

  Widget _buildProgressBar(TimerState timerState) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: timerState.progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            timerState.isFinished ? Colors.green : Colors.blue,
          ),
        ),
      ),
    );
  }

  void _startEditing(TimerState timerState) {
    setState(() {
      _isEditingTime = true;
      final currentMinutes = timerState.remainingTime ~/ 60;
      final currentSeconds = timerState.remainingTime % 60;
      _minutesController.text = currentMinutes.toString().padLeft(2, '0');
      _secondsController.text = currentSeconds.toString().padLeft(2, '0');
    });
    _minutesFocus.requestFocus();
  }

  void _finishEditing(TimerState timerState) {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;
    
    if (totalSeconds > 0 && totalSeconds <= 7200) { // Max 2 hours
      timerState.setCustomDuration(totalSeconds);
    }
    
    setState(() {
      _isEditingTime = false;
    });
  }

  void _cancelEditing(TimerState timerState) {
    setState(() {
      _isEditingTime = false;
    });
  }

  Widget _buildControlButtons(BuildContext context, TimerState timerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Start/Pause Button
        _buildControlButton(
          onPressed: timerState.canStart ? timerState.start : 
                   timerState.isRunning ? timerState.pause : null,
          icon: timerState.isRunning ? Icons.pause : Icons.play_arrow,
          label: timerState.isRunning ? 'Pause' : 'Start',
          isPrimary: true,
        ),
        
        const SizedBox(width: 20),
        
        // Reset Button
        _buildControlButton(
          onPressed: timerState.status != TimerStatus.initial ? timerState.reset : null,
          icon: Icons.refresh,
          label: 'Reset',
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.blue : Colors.grey[300],
          foregroundColor: isPrimary ? Colors.white : Colors.black54,
          elevation: isPrimary ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusButton(BuildContext context, TimerState timerState) {
    return SizedBox(
      width: 200,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Remember current tab and enter focus mode
          timerState.enterFocusMode(false); // false = timer mode
          await WindowService.setupFocusMode();
        },
        icon: const Icon(Icons.center_focus_strong),
        label: const Text('Enter Focus Mode'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }

  Widget _buildStopwatchButtons(BuildContext context, TimerState timerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Start/Pause Button
        _buildControlButton(
          onPressed: timerState.stopwatchStatus == StopwatchStatus.initial || timerState.isStopwatchPaused
              ? timerState.startStopwatch
              : timerState.isStopwatchRunning
                  ? timerState.pauseStopwatch
                  : null,
          icon: timerState.isStopwatchRunning ? Icons.pause : Icons.play_arrow,
          label: timerState.isStopwatchRunning ? 'Pause' : 'Start',
          isPrimary: true,
        ),
        
        const SizedBox(width: 20),
        
        // Reset Button
        _buildControlButton(
          onPressed: timerState.stopwatchStatus != StopwatchStatus.initial ? timerState.resetStopwatch : null,
          icon: Icons.refresh,
          label: 'Reset',
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildStopwatchFocusButton(BuildContext context, TimerState timerState) {
    return SizedBox(
      width: 200,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Remember current tab and enter focus mode
          timerState.enterFocusMode(true); // true = stopwatch mode
          await WindowService.setupFocusMode();
        },
        icon: const Icon(Icons.center_focus_strong),
        label: const Text('Enter Focus Mode'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
