import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_state.dart';
import '../services/window_service.dart';

class FocusTimerView extends StatelessWidget {
  const FocusTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: Consumer<TimerState>(
        builder: (context, timerState, child) {
          return Center(
            child: Container(
              width: 280,
              height: 66,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Left side: Timer only (no progress bar)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Compact Timer/Stopwatch Display
                        Text(
                          timerState.isFocusMode && timerState.isStopwatchRunning 
                              ? timerState.stopwatchFormattedTime 
                              : timerState.formattedTime,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Right side: Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pause/Resume button
                      GestureDetector(
                        onTap: () {
                          if (timerState.isStopwatchRunning) {
                            timerState.pauseStopwatch();
                          } else if (timerState.isStopwatchPaused) {
                            timerState.startStopwatch();
                          } else if (timerState.isRunning) {
                            timerState.pause();
                          } else if (timerState.isPaused) {
                            timerState.start();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            (timerState.isRunning || timerState.isStopwatchRunning) ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Exit Focus Mode Button
                      GestureDetector(
                        onTap: () async {
                          timerState.toggleFocusMode();
                          await WindowService.exitFocusMode();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
