import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_state.dart';
import '../services/window_service.dart';

class MainTimerView extends StatefulWidget {
  const MainTimerView({super.key});

  @override
  State<MainTimerView> createState() => _MainTimerViewState();
}

class _MainTimerViewState extends State<MainTimerView> {
  bool _isEditingTime = false;
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  final FocusNode _minutesFocus = FocusNode();
  final FocusNode _secondsFocus = FocusNode();

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _minutesFocus.dispose();
    _secondsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TimerState>(
        builder: (context, timerState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 64,
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
                  const SizedBox(height: 40),
                  
                  // Timer Display
                  _buildTimerDisplay(timerState),
                  const SizedBox(height: 30),
                  
                  // Progress Bar
                  _buildProgressBar(timerState),
                  const SizedBox(height: 40),
                  
                  // Duration Selector (only when not running) - Now just empty space
                  if (timerState.status == TimerStatus.initial)
                    const SizedBox(height: 0),
                  
                  const SizedBox(height: 30),
                  
                  // Control Buttons
                  _buildControlButtons(context, timerState),
                  
                  // Focus Button (only when running)
                  if (timerState.canFocus) ...[
                    const SizedBox(height: 20),
                    _buildFocusButton(context, timerState),
                  ],
                ],
              ),
            ),
          );
        },
      ),
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
          timerState.toggleFocusMode();
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
