// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:share/share.dart';
// import 'log_provider.dart'; // Ensure correct import path
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Behavior Logger'),
//       ),
//       body: Column(
//         children: [
//           // Behavior Buttons
//           Expanded(
//             flex: 1,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Wrap(
//                 spacing: 10,
//                 children: ['1:Toilet', '2:Wash', '3:Shower', '3:Cleaning', '5:ETC', '6:Bath'].map((behavior) {
//                   return Consumer<LogProvider>(
//                     builder: (context, logProvider, child) {
//                       final isInProgress = logProvider.isBehaviorInProgress(behavior);
//                       return ElevatedButton(
//                         onPressed: () => logProvider.toggleLog(behavior),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Provider.of<LogProvider>(context).isBehaviorInProgress(behavior) ? Colors.red : Colors.blue, // Adjusted property for background color
//                           foregroundColor: Colors.white, // Adjusted property for text/icon color
//                         ),
//                         child: Text(behavior),
//                       );
//                     },
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//           // Log Terminal
//           Expanded(
//             flex: 2,
//             child: Consumer<LogProvider>(
//               builder: (context, logProvider, child) {
//                 return ListView.builder(
//                   itemCount: logProvider.logs.length,
//                   itemBuilder: (context, index) {
//                     final log = logProvider.logs[index];
//                     return ListTile(
//                       title: Text(log.name),
//                       subtitle: Text('${log.start} - ${log.end ?? 'In Progress'}'),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           final logsString = Provider.of<LogProvider>(context, listen: false).getLogsAsString();
//           Share.share(logsString);
//         },
//         child: Icon(Icons.share),
//         tooltip: 'Share Logs',
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'log_provider.dart'; // Ensure correct import path

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Behavior Logger'),
      ),
      body: Column(
        children: [
          // "In Room" Button
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {
                // Use toggleInRoomBehavior for the "In Room" button
                Provider.of<LogProvider>(context, listen: false).toggleInRoom();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Provider.of<LogProvider>(context).isBehaviorInProgress("재실") ? Colors.red : Colors.green,
              ),
              child: Text("재실"),
            // child: ElevatedButton(
            //   onPressed: () => logProvider.toggleInRoom(), // Use toggleInRoom for specific handling
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: logProvider.isBehaviorInProgress("In Room") ? Colors.red : Colors.green,
            //   ),
            //   child: Text("In Room"),
            ),
          ),
          // Behavior Buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 2,
                children: [
                  '1:Toilet', '2:세면', '3:샤워',  '4:청소', '5:기타', '6:목욕'
                ].map((behavior) {
                  return ElevatedButton(
                    onPressed: () {
                      if (behavior != "재실") { // Check to prevent recursive calls for "In Room"
                        logProvider.ensureInRoomStarted(); // Automatically start "In Room" log
                      }
                      logProvider.toggleLog(behavior);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logProvider.isBehaviorInProgress(behavior) ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(behavior),
                  );
                }).toList(),
              ),
            ),
          ),

          // Log Terminal
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: logProvider.logs.length,
              itemBuilder: (context, index) {
                final reversedIndex = logProvider.logs.length - 1 - index;
                final log = logProvider.logs[reversedIndex];
                return GestureDetector(
                  onLongPress: () => _showEditDialog(context, logProvider, reversedIndex),
                    child: ListTile(
                    title: Text(log.name),
                    subtitle: Text('시작:${log.start}\n종료:${log.end?.toString() ?? 'In Progress'}'),
                    trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showEditDialog(context, logProvider, reversedIndex),
                    ),
                  ),
                );
              },
            ),
          ),




          // // Log Terminal
          // Expanded(
          //   flex: 2,
          //   child: ListView.builder(
          //     itemCount: logProvider.logs.length,
          //     itemBuilder: (context, index) {
          //       // Calculate the reversed index to display newest logs at the top
          //       final reversedIndex = logProvider.logs.length - 1 - index;
          //       final log = logProvider.logs[reversedIndex];
          //       return ListTile(
          //         title: Text(log.name),
          //         subtitle: Text('${log.start} - ${log.end?.toString() ?? 'In Progress'}'),
          //       );
          //       // final log = logProvider.logs[index];
          //       // return ListTile(
          //       //   title: Text(log.name),
          //       //   subtitle: Text('${log.start} - ${log.end?.toString() ?? 'In Progress'}'),
          //       // );
          //     },
          //   ),
          // ),


        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final logsString = logProvider.getLogsAsString();
          Share.share(logsString);
        },
        child: Icon(Icons.share),
        tooltip: 'Share Logs',
      ),
    );
  }

  // Future<void> _showEditDialog(BuildContext context, LogProvider logProvider, int index) async {
  //   TextEditingController _controller = TextEditingController();
  //   _controller.text = logProvider.logs[index].name;
  //
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Edit Log'),
  //         content: TextField(
  //           controller: _controller,
  //           decoration: InputDecoration(
  //             hintText: "Enter new name",
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Save'),
  //             onPressed: () {
  //               logProvider.updateLog(index, name: _controller.text);
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  Future<void> _showEditDialog(BuildContext context, LogProvider logProvider, int index) async {
    TextEditingController nameController = TextEditingController();
    LogEntry log = logProvider.logs[index];
    nameController.text = log.name;

    // Temporary variables to hold edits
    DateTime? editedStart = log.start;
    DateTime? editedEnd = log.end;

    // Function to handle date and time picking
    Future<DateTime?> _pickDateTime(BuildContext context, DateTime initialDate) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );
      if (pickedDate == null) return null;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (pickedTime == null) return null;

      return DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('로그 수정'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "수정이 필요한 경우 새로운 이름 입력해주세요"),
                ),
                TextButton(
                  onPressed: () async {
                    final DateTime? newStart = await _pickDateTime(context, log.start);
                    if (newStart != null) {
                      editedStart = newStart;
                    }
                  },
                  child: Text('시작 시간 변경'),
                ),
                TextButton(
                  onPressed: () async {
                    final DateTime? newEnd = await _pickDateTime(context, log.end ?? DateTime.now());
                    if (newEnd != null) {
                      editedEnd = newEnd;
                    }
                  },
                  child: Text('종료 시간 변경'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                logProvider.removeLog(index);
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                logProvider.updateLog(index, name: nameController.text, startTime: editedStart, endTime: editedEnd);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
