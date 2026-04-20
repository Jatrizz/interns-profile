import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_stats_cards.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_filters.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_table.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_pagination.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_legend.dart';
import 'package:interfaces/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternTimeLogsPage extends StatefulWidget {
  final String firstName;
  const InternTimeLogsPage({super.key, required this.firstName});

  @override
  State<InternTimeLogsPage> createState() => _InternTimeLogsPageState();
}

class _InternTimeLogsPageState extends State<InternTimeLogsPage> {
  bool isDarkMode = true;

  int totalHours = 0;
  int remainingHours = 0;
  int lateArrivals = 0;
  int absences = 0;

  String selectedMonth = 'April 2026';
  String selectedStatus = 'All';
  String selectedWeek = 'All Weeks';

  int currentPage = 1;
  int totalEntries = 0;
  int entriesPerPage = 8;

  List<Map<String, dynamic>> allLogs = [];
  List<Map<String, dynamic>> filteredLogs = [];

  @override
  void initState() {
    super.initState();
    fetchTimeLogs();
    fetchTimeLogStats();
  }

  Future<void> fetchTimeLogStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/timelogs/stats'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalHours = data['total_hours'] ?? 0;
          remainingHours = data['remaining_hours'] ?? 0;
          lateArrivals = data['late_arrivals'] ?? 0;
          absences = data['absences'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching time log stats: $e');
    }
  }

  Future<void> fetchTimeLogs() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/timelogs'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allLogs = data.map((e) => Map<String, dynamic>.from(e)).toList();
          applyFilters();
        });
      }
    } catch (e) {
      print('Error fetching time logs: $e');
      // Mock data fallback
      setState(() {
        allLogs = [
          {
            'date': 'April 14',
            'day': 'Tue',
            'time_in': '8:00 AM',
            'time_out': '–',
            'total_hours': 'In Progress',
            'status': 'Present',
          },
          {
            'date': 'April 13',
            'day': 'Mon',
            'time_in': '8:00 AM',
            'time_out': '5:00 PM',
            'total_hours': '8h',
            'status': 'Present',
          },
          {
            'date': 'April 12',
            'day': 'Sun',
            'time_in': '–',
            'time_out': '–',
            'total_hours': '–',
            'status': 'Weekend',
          },
          {
            'date': 'April 11',
            'day': 'Sat',
            'time_in': '–',
            'time_out': '–',
            'total_hours': '–',
            'status': 'Weekend',
          },
          {
            'date': 'April 10',
            'day': 'Fri',
            'time_in': '8:12 AM',
            'time_out': '5:00 PM',
            'total_hours': '7h 48m',
            'status': 'Late',
          },
          {
            'date': 'April 9',
            'day': 'Thu',
            'time_in': '8:00 AM',
            'time_out': '5:00 PM',
            'total_hours': '8h',
            'status': 'Present',
          },
          {
            'date': 'April 8',
            'day': 'Wed',
            'time_in': '8:02 AM',
            'time_out': '5:00 PM',
            'total_hours': '7h 58m',
            'status': 'Late',
          },
          {
            'date': 'April 7',
            'day': 'Tue',
            'time_in': '7:45 AM',
            'time_out': '5:00 PM',
            'total_hours': '8h',
            'status': 'Present',
          },
          {
            'date': 'April 6',
            'day': 'Mon',
            'time_in': '–',
            'time_out': '–',
            'total_hours': '–',
            'status': 'Absent',
          },
          {
            'date': 'April 5',
            'day': 'Sun',
            'time_in': '–',
            'time_out': '–',
            'total_hours': '–',
            'status': 'Weekend',
          },
          {
            'date': 'April 4',
            'day': 'Sat',
            'time_in': '–',
            'time_out': '–',
            'total_hours': '–',
            'status': 'Weekend',
          },
          {
            'date': 'April 3',
            'day': 'Fri',
            'time_in': '8:00 AM',
            'time_out': '1:00 PM',
            'total_hours': '5h',
            'status': 'Half Day',
          },
          {
            'date': 'April 2',
            'day': 'Thu',
            'time_in': '8:00 AM',
            'time_out': '5:00 PM',
            'total_hours': '8h',
            'status': 'Present',
          },
          {
            'date': 'April 1',
            'day': 'Wed',
            'time_in': '8:00 AM',
            'time_out': '5:00 PM',
            'total_hours': '8h',
            'status': 'Present',
          },
        ];
        applyFilters();
      });
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> result = List.from(allLogs);

    if (selectedStatus != 'All') {
      result = result.where((log) => log['status'] == selectedStatus).toList();
    }

    // Week filter logic can be extended here

    setState(() {
      filteredLogs = result;
      totalEntries = result.length;
      currentPage = 1;
    });
  }

  List<Map<String, dynamic>> get paginatedLogs {
    final start = (currentPage - 1) * entriesPerPage;
    final end = (start + entriesPerPage).clamp(0, filteredLogs.length);
    return filteredLogs.sublist(start, end);
  }

  int get totalPages => (totalEntries / entriesPerPage).ceil();

  Future<void> handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF242424) : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Logs',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InternTimeLogStatsCards(
            isDarkMode: isDarkMode,
            totalHours: totalHours,
            remainingHours: remainingHours,
            lateArrivals: lateArrivals,
            absences: absences,
          ),
          const SizedBox(height: 24),
          InternTimeLogFilters(
            isDarkMode: isDarkMode,
            selectedMonth: selectedMonth,
            selectedStatus: selectedStatus,
            selectedWeek: selectedWeek,
            onMonthChanged: (val) => setState(() => selectedMonth = val),
            onStatusChanged: (val) {
              setState(() => selectedStatus = val);
              applyFilters();
            },
            onWeekChanged: (val) => setState(() => selectedWeek = val),
          ),
          const SizedBox(height: 16),
          InternTimeLogTable(
            isDarkMode: isDarkMode,
            logs: paginatedLogs,
          ),
          const SizedBox(height: 12),
          InternTimeLogPagination(
            isDarkMode: isDarkMode,
            currentPage: currentPage,
            totalPages: totalPages,
            totalEntries: totalEntries,
            entriesPerPage: entriesPerPage,
            shownCount: paginatedLogs.length,
            onPageChanged: (page) => setState(() => currentPage = page),
          ),
          const SizedBox(height: 16),
          InternTimeLogLegend(isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}
