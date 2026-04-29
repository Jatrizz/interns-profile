import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_stats_cards.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_filters.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_table.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_pagination.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_legend.dart';
import 'package:interfaces/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternTimeLogsPage extends StatefulWidget {
  final String firstName;
  final String userId;
  final bool isDarkMode;

  const InternTimeLogsPage({
    super.key,
    required this.firstName,
    required this.userId,
    required this.isDarkMode,
  });

  @override
  State<InternTimeLogsPage> createState() => _InternTimeLogsPageState();
}

class _InternTimeLogsPageState extends State<InternTimeLogsPage> {
  bool get isDarkMode => widget.isDarkMode;

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

  bool _isSpecificDate = false;
  DateTime? selectedDate;

  late Timer _refreshTimer;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    fetchTimeLogs();
    fetchTimeLogStats();

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted || _isFetching) return;
      _isFetching = true;
      await fetchTimeLogs();
      await fetchTimeLogStats();
      _isFetching = false;
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> fetchTimeLogStats() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8080/intern/timelogs/stats?user_id=${widget.userId}'),
      );
      if (!mounted) return;
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
      debugPrint('Error fetching time log stats: $e');
    }
  }

  Future<void> fetchTimeLogs() async {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    String url;
    if (_isSpecificDate && selectedDate != null) {
      final date = selectedDate!.toIso8601String().split('T')[0];
      url =
          'http://127.0.0.1:8080/intern/timelogs?user_id=${widget.userId}&date=$date';
    } else {
      final parts = selectedMonth.split(' ');
      final monthIndex = months.indexOf(parts[0]) + 1;
      final year = parts[1];
      url =
          'http://127.0.0.1:8080/intern/timelogs?user_id=${widget.userId}&month=$monthIndex&year=$year';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allLogs = data.map((e) => Map<String, dynamic>.from(e)).toList();
          applyFilters();
        });
      }
    } catch (e) {
      debugPrint('>>> Error fetching time logs: $e');
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> result = List.from(allLogs);

    if (selectedStatus != 'All') {
      result = result.where((log) {
        final status = log['status']?.toString().toLowerCase() ?? '';
        if (selectedStatus == 'Present') {
          return status == 'on-time' || status == 'late';
        }
        if (selectedStatus == 'On Time') {
          return status == 'on-time';
        }
        if (selectedStatus == 'Half Day') {
          return status == 'half-day' || status == 'halfday';
        }
        return status == selectedStatus.toLowerCase();
      }).toList();
    }

    if (selectedWeek != 'All Weeks') {
      final weekNumber = int.tryParse(selectedWeek.replaceAll('Week ', ''));
      if (weekNumber != null) {
        result = result.where((log) {
          final date = log['date']?.toString() ?? '';
          final parts = date.split(' ');
          if (parts.length == 2) {
            final day = int.tryParse(parts[1]);
            if (day != null) {
              final week = ((day - 1) ~/ 7) + 1;
              return week == weekNumber;
            }
          }
          return false;
        }).toList();
      }
    }

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

  int get totalPages =>
      totalEntries == 0 ? 1 : (totalEntries / entriesPerPage).ceil();

  Future<void> handleLogout() async {
    final theme = AppTheme.of(isDarkMode);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.sidebarBg,
        title: Text(
          'Logout',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: theme.textSecondary),
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
        pageBuilder: (_, __, ___) => LoginPage(
          isDarkMode: isDarkMode,
          onToggleTheme: () {},
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(isDarkMode);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Logs',
            style: TextStyle(
              color: theme.textPrimary,
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
            isSpecificDate: _isSpecificDate,
            onToggleMode: (val) {
              final now = DateTime.now();
              final months = [
                'January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'
              ];
              setState(() {
                _isSpecificDate = val;
                if (val) {
                  selectedDate = now;
                  selectedMonth =
                      '${months[now.month - 1]} ${now.day}, ${now.year}';
                } else {
                  selectedDate = null;
                  selectedMonth = '${months[now.month - 1]} ${now.year}';
                }
              });
              fetchTimeLogs();
            },
            onMonthChanged: (DateTime picked) {
              final months = [
                'January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'
              ];
              setState(() {
                selectedDate = picked;
                if (_isSpecificDate) {
                  selectedMonth =
                      '${months[picked.month - 1]} ${picked.day}, ${picked.year}';
                } else {
                  selectedMonth =
                      '${months[picked.month - 1]} ${picked.year}';
                }
              });
              fetchTimeLogs();
            },
            onStatusChanged: (val) {
              setState(() => selectedStatus = val);
              applyFilters();
            },
            onWeekChanged: (val) {
              setState(() => selectedWeek = val);
              applyFilters();
            },
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