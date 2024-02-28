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
                backgroundColor: Provider.of<LogProvider>(context).isBehaviorInProgress("In Room") ? Colors.red : Colors.green,
              ),
              child: Text("In Room"),
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
                  '1:Toilet', '2:Wash', '3:Shower',  '4:Cleaning', '5:ETC', '6:Bath'
                ].map((behavior) {
                  return ElevatedButton(
                    onPressed: () {
                      if (behavior != "In Room") { // Check to prevent recursive calls for "In Room"
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
                // Calculate the reversed index to display newest logs at the top
                final reversedIndex = logProvider.logs.length - 1 - index;
                final log = logProvider.logs[reversedIndex];
                return ListTile(
                  title: Text(log.name),
                  subtitle: Text('${log.start} - ${log.end?.toString() ?? 'In Progress'}'),
                );
                // final log = logProvider.logs[index];
                // return ListTile(
                //   title: Text(log.name),
                //   subtitle: Text('${log.start} - ${log.end?.toString() ?? 'In Progress'}'),
                // );
              },
            ),
          ),


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
}
