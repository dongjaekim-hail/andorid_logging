import 'package:flutter/foundation.dart';
import 'storage_manager.dart';

class LogEntry {
  String name;
  DateTime start;
  DateTime? end;

  LogEntry({required this.name, required this.start, this.end});

  @override
  String toString() {
    return "$name - Start: $start, End: ${end ?? 'In Progress'}";
  }
}

class LogProvider with ChangeNotifier {
  List<LogEntry> _logs = [];

  LogProvider() {
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    _logs = await StorageManager.loadLogs();
    notifyListeners();
  }

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void addLog(String behaviorName) {
    _logs.add(LogEntry(name: behaviorName, start: DateTime.now()));
    notifyListeners();
    saveLogs();
  }

  void endLog(String behaviorName) {
    LogEntry? matchingLog;
    for (var log in _logs) {
      if (log.name == behaviorName && log.end == null) {
        matchingLog = log;
        break; // Stop the loop once the first matching log is found
      }
    }

    if (matchingLog != null) {
      matchingLog.end = DateTime.now();
      notifyListeners();
      saveLogs();
    }
  }

  void toggleLog(String behaviorName) {
    LogEntry? matchingLog;
    for (var log in _logs) {
      if (log.name == behaviorName && log.end == null) {
        matchingLog = log;
        break; // Identifies if there's an ongoing log for this behavior
      }
    }


    if (matchingLog != null) {
      endLog(behaviorName); // Ends the log if it's in progress
    } else {
      addLog(behaviorName); // Starts a new log if none is in progress
      if (behaviorName != "In Room") {
        // Ensure "In Room" is logged first if not already
        ensureInRoomStarted();
      }
    }
  }


  // // Special handling for "In Room" behavior
  // void toggleInRoomBehavior() {
  //   bool isInRoomActive = _logs.any((log) => log.name == "In Room" && log.end == null);
  //
  //   if (!isInRoomActive) {
  //     // If "In Room" is not active, start it
  //     addLog("In Room");
  //   } else {
  //     // If "In Room" is active, end it along with all other behaviors
  //     endAllBehaviors();
  //   }
  // }
  void toggleInRoom() {
    // Check if "In Room" is currently in progress
    bool isRoomLogActive = isBehaviorInProgress("In Room");

    if (!isRoomLogActive) {
      // If not, start "In Room" log
      addLog("In Room");
    } else {
      // If "In Room" is active, end it and all other logs
      endAllBehaviors();
    }
  }

  void endAllBehaviors() {
    DateTime now = DateTime.now();
    for (var log in _logs.where((log) => log.end == null)) {
      log.end = now;
    }
    notifyListeners();
  }

  bool isBehaviorInProgress(String behaviorName) {
    return _logs.any((log) => log.name == behaviorName && log.end == null);
  }

  String getLogsAsString() {
    return _logs.map((log) => log.toString()).join('\n');
  }

  // Ensures "In Room" behavior is started
  void ensureInRoomStarted() {
    if (!isBehaviorInProgress("In Room")) {
      addLog("In Room");
    }
  }

  // Ends all in-progress logs
  void endAllLogs() {
    for (var log in _logs.where((log) => log.end == null)) {
      log.end = DateTime.now();
    }
    notifyListeners();
    saveLogs();
  }

  // Save logs to storage
  void saveLogs() async {
    await StorageManager.saveLogs(_logs);
  }

  // Load logs from storage
  void loadLogs() async {
    _logs = await StorageManager.loadLogs();
    notifyListeners();
  }


}
