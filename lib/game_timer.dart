import 'dart:async';
import 'package:flutter/material.dart';

class GameTimer extends ChangeNotifier {
  Timer? _timer;
  int _seconds = 0;

  // Mevcut getter'ın (varsa kullanan yerler bozulmasın diye kalsın)
  int get seconds => _seconds;

  // Oyun ekranlarının (CupGameScreen vb.) süreyi okuması için gerekli getter:
  int get elapsedSeconds => _seconds;

  String get formattedTime {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:"
        "${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _seconds++;
        notifyListeners();
      },
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    stop();
    _seconds = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}