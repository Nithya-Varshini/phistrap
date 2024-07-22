import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class CallLogScreen extends StatefulWidget {
  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<CallLogEntry> callLogs = [];
  List<CallLogEntry> filteredLogs = [];
  bool isFilterApplied = false;
  CallType? selectedCallType;
  bool isDarkThemeEnabled = false; 

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadCallLogs();
  }

  Future<void> _checkPermissionAndLoadCallLogs() async {
    if (await Permission.phone.request().isGranted) {
      _loadCallLogs();
    } else {
      showToast("Please provide phone permission");
      openAppSettings();
    }
  }

  Future<void> _loadCallLogs() async {
    Iterable<CallLogEntry> entries = await CallLog.get();
    setState(() {
      callLogs = entries.toList();
    });
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: isFilterApplied ? filteredLogs.length : callLogs.length,
        itemBuilder: (context, index) {
          final CallLogEntry log =
              isFilterApplied ? filteredLogs[index] : callLogs[index];
          Color iconColor;
          IconData leadingIcon;

          if (log.callType == CallType.incoming) {
            iconColor = Colors.blue;
            leadingIcon = Icons.call_received;
          } else if (log.callType == CallType.outgoing) {
            iconColor = Colors.green;
            leadingIcon = Icons.call_made;
          } else if (log.callType == CallType.missed) {
            iconColor = Colors.red;
            leadingIcon = Icons.call_missed;
          } else {
            iconColor = Color(0xFF000000); 
            leadingIcon = Icons.call; 
          }

          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Color(00000), width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              tileColor: Color.fromARGB(255, 255, 255, 255),
              leading: Icon(
                leadingIcon,
                color: iconColor,
              ),
              
              title:
                  Text('${log.name ?? 'Unknown'} : ${log.number ?? 'Unknown'}'),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration: ${_formatDuration(log.duration)} | Time: ${_formatTime(log.timestamp)}',
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Report Submitted"),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor:
                          Colors.white, 
                      side: BorderSide(
                          color: Colors.red), 
                      minimumSize: Size(0,
                          30),
                    ),
                    child: Text("Report Spam"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    _clearFilter(); 
    await _loadCallLogs(); 
  }

  void _applyFilter() {
    if (selectedCallType != null) {
      setState(() {
        filteredLogs =
            callLogs.where((log) => log.callType == selectedCallType).toList();
        isFilterApplied = true;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      isFilterApplied = false;
      selectedCallType = null; 
      filteredLogs.clear(); 
    });
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return 'Unknown';
    final Duration duration = Duration(seconds: seconds);
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
