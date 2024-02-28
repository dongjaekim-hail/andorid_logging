import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'log_provider.dart';

class StorageManager {
  // Path for storing the logs file.
  static String _fileName = 'logs.json';

  // Save logs to a file
  static Future<void> saveLogs(List<LogEntry> logs) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');
    final logsJson = logs
        .map((log) => {
      'name': log.name,
      'start': log.start.toIso8601String(),
      'end': log.end?.toIso8601String(),
    })
        .toList();
    await file.writeAsString(json.encode(logsJson));
  }

  // Load logs from a file
  static Future<List<LogEntry>> loadLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      final String contents = await file.readAsString();
      final List<dynamic> jsonResponse = json.decode(contents);
      return jsonResponse
          .map((logData) => LogEntry(
        name: logData['name'],
        start: DateTime.parse(logData['start']),
        end: logData['end'] != null ? DateTime.parse(logData['end']) : null,
      ))
          .toList();
    } catch (e) {
      // If encountering an error, return empty list
      return [];
    }
  }
}
