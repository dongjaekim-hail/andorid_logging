import 'package:flutter/foundation.dart';
import 'storage_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    DateTime now = DateTime.now();
    // Remove milliseconds and microseconds
    DateTime cleanNow = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
    _logs.add(LogEntry(name: behaviorName, start: cleanNow));
    notifyListeners();
    saveLogs();
  }
  // void addLog(String behaviorName) {
  //   _logs.add(LogEntry(name: behaviorName, start: DateTime.now()));
  //   notifyListeners();
  //   saveLogs();
  // }
  void endLog(String behaviorName) {
    LogEntry? matchingLog;
    for (var log in _logs) {
      if (log.name == behaviorName && log.end == null) {
        matchingLog = log;
        break; // Stop the loop once the first matching log is found
      }
    }

    if (matchingLog != null) {
      DateTime now = DateTime.now();
      // Remove milliseconds and microseconds
      DateTime cleanNow = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
      matchingLog.end = cleanNow;
      notifyListeners();
      saveLogs();
    }
  }
  // void endLog(String behaviorName) {
  //   LogEntry? matchingLog;
  //   for (var log in _logs) {
  //     if (log.name == behaviorName && log.end == null) {
  //       matchingLog = log;
  //       break; // Stop the loop once the first matching log is found
  //     }
  //   }
  //
  //   if (matchingLog != null) {
  //     matchingLog.end = DateTime.now();
  //     notifyListeners();
  //     saveLogs();
  //   }
  // }

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
      if (behaviorName != "재실") {
        // Ensure "In Room" is logged first if not already
        ensureInRoomStarted();
      }
    }
  }


  void updateLog(int index, {String? name, DateTime? startTime, DateTime? endTime}) {
    var log = _logs[index];
    if (name != null) log.name = name;
    if (startTime != null) {
      // Remove milliseconds and microseconds from startTime
      DateTime cleanStartTime = DateTime(startTime.year, startTime.month, startTime.day, startTime.hour, startTime.minute, startTime.second);
      log.start = cleanStartTime;
    }
    if (endTime != null) {
      // Remove milliseconds and microseconds from endTime
      DateTime cleanEndTime = DateTime(endTime.year, endTime.month, endTime.day, endTime.hour, endTime.minute, endTime.second);
      log.end = cleanEndTime;
    }
    notifyListeners();
  }


  // void updateLog(int index, {String? name, DateTime? startTime, DateTime? endTime}) {
  //   var log = _logs[index];
  //   if (name != null) log.name = name;
  //   if (startTime != null) log.start = startTime;
  //   if (endTime != null) log.end = endTime;
  //   notifyListeners();
  // }


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
    bool isRoomLogActive = isBehaviorInProgress("재실");

    if (!isRoomLogActive) {
      // If not, start "In Room" log
      addLog("재실");
    } else {
      // If "In Room" is active, end it and all other logs
      endAllBehaviors();
    }
  }

  void endAllBehaviors() {
    DateTime now = DateTime.now();
    DateTime cleanNow = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);

    for (var log in _logs.where((log) => log.end == null)) {
      log.end = cleanNow;
    }
    notifyListeners();
    saveLogs();
  }

  bool isBehaviorInProgress(String behaviorName) {
    return _logs.any((log) => log.name == behaviorName && log.end == null);
  }

  String getLogsAsString() {
    return _logs.map((log) => log.toString()).join('\n');
  }

  // Ensures "In Room" behavior is started
  void ensureInRoomStarted() {
    if (!isBehaviorInProgress("재실")) {
      addLog("재실");
    }
  }

  // Ends all in-progress logs
  void endAllLogs() {
    for (var log in _logs.where((log) => log.end == null)) {
      DateTime now = DateTime.now();
      DateTime cleanNow = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
      log.end = cleanNow;
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


  // Future<void> _loadLogs() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // Assuming logs are serialized as a JSON string; adjust based on your implementation
  //   String? logsJson = prefs.getString('logs');
  //   if (logsJson != null) {
  //     // Deserialize logsJson into _logs
  //     // For example, if you're using a package like json_serializable
  //     // _logs = LogEntry.decode(logsJson);
  //     notifyListeners();
  //   }
  //   _checkInRoomStatus();
  // }

  // void _checkInRoomStatus() {
  //   // Check if "In Room" is active based on _logs state and adjust app state accordingly
  //   bool isInRoomActive = isBehaviorInProgress("In Room");
  //   if (!isInRoomActive) {
  //     // Handle case where "In Room" should not be active
  //   }
  // }

  void _checkInRoomStatus() {
    // Check if "In Room" is active based on _logs state and adjust app state accordingly
    bool isInRoomActive = isBehaviorInProgress("재실");
    if (!isInRoomActive) {
      // Handle case where "In Room" should not be active
    }
  }

  void removeLog(int index) {
    _logs.removeAt(index);
    notifyListeners();
  }


}
