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
              width: 220,
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Compact Timer Display
                  Text(
                    timerState.formattedTime,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  
                  // Minimal Progress Bar
                  Container(
                    width: 160,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: timerState.progress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          timerState.isFinished ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  
                  // Control buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pause/Resume button
                      GestureDetector(
                        onTap: () {
                          if (timerState.isRunning) {
                            timerState.pause();
                          } else if (timerState.isPaused) {
                            timerState.start();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            timerState.isRunning ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      
                      // Exit Focus Mode Button
                      GestureDetector(
                        onTap: () async {
                          timerState.toggleFocusMode();
                          await WindowService.exitFocusMode();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
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
