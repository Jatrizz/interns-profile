import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_filters.dart';
import '../widgets/Intern-TimeLog-Widgets/intern_time_log_table.dart';
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
  int presentDays = 0;

  String selectedMonth = () {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }();

  String selectedStatus = 'All';
  String selectedWeek = 'All Weeks';

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
  void didUpdateWidget(InternTimeLogsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetToCurrentMonth();
  }

  void _resetToCurrentMonth() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final currentMonth = '${months[now.month - 1]} ${now.year}';
    if (selectedMonth != currentMonth && !_isSpecificDate) {
      setState(() {
        selectedMonth = currentMonth;
        selectedDate = null;
      });
      fetchTimeLogs();
    }
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> fetchTimeLogStats() async {
    try {
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:8080/intern/timelogs/stats?user_id=${widget.userId}'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          presentDays = data['present_days'] ?? 0;
          lateArrivals = data['late_arrivals'] ?? 0;
          absences = data['absences'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching time log stats: $e');
    }
  }

  Future<void> fetchTimeLogs() async {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String url;
    if (_isSpecificDate && selectedDate != null) {
      final date = selectedDate!.toIso8601String().split('T')[0];
      url = 'http://127.0.0.1:8080/intern/timelogs?user_id=${widget.userId}&date=$date';
    } else {
      final parts = selectedMonth.split(' ');
      final monthIndex = months.indexOf(parts[0]) + 1;
      final year = parts[1];
      url = 'http://127.0.0.1:8080/intern/timelogs?user_id=${widget.userId}&month=$monthIndex&year=$year';
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
        if (selectedStatus == 'Present') return status == 'on-time' || status == 'late';
        if (selectedStatus == 'On Time') return status == 'on-time';
        if (selectedStatus == 'Half Day') return status == 'half-day' || status == 'halfday';
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
            if (day != null) return ((day - 1) ~/ 7) + 1 == weekNumber;
          }
          return false;
        }).toList();
      }
    }
    setState(() => filteredLogs = result);
  }

  Future<void> handleLogout() async {
    final theme = AppTheme.of(isDarkMode);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.sidebarBg,
        title: Text('Logout',
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(color: theme.textSecondary)),
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
        pageBuilder: (_, __, ___) =>
            LoginPage(isDarkMode: isDarkMode, onToggleTheme: () {}),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  Widget _buildStatCards(BuildContext context) {
    final mobile = _isMobile(context);

    final cards = [
      _StatCard(isDarkMode: isDarkMode, label: 'Present Days',  value: '$presentDays',  accentColor: const Color(0xFF4CAF50)),
      _StatCard(isDarkMode: isDarkMode, label: 'Late Arrivals', value: '$lateArrivals', accentColor: const Color(0xFFFFA726)),
      _StatCard(isDarkMode: isDarkMode, label: 'Absences',      value: '$absences',     accentColor: const Color(0xFFEF5350)),
    ];

    final gap = SizedBox(width: mobile ? 10.0 : 12.0);

    return Row(
      children: [
        Expanded(child: cards[0]),
        gap,
        Expanded(child: cards[1]),
        gap,
        Expanded(child: cards[2]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(isDarkMode);
    final mobile = _isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(mobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──────────────────────────────────
          Text(
            'Time Logs',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: mobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: mobile ? 12 : 16),

          // ── Stat cards ─────────────────────────────
          _buildStatCards(context),
          SizedBox(height: mobile ? 16 : 24),

          // ── Filters ────────────────────────────────
          InternTimeLogFilters(
            isDarkMode: isDarkMode,
            selectedMonth: selectedMonth,
            selectedStatus: selectedStatus,
            selectedWeek: selectedWeek,
            isSpecificDate: _isSpecificDate,
            onToggleMode: (val) {
              final now = DateTime.now();
              const months = [
                'January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'
              ];
              setState(() {
                _isSpecificDate = val;
                if (val) {
                  selectedDate = now;
                  selectedMonth = '${months[now.month - 1]} ${now.day}, ${now.year}';
                } else {
                  selectedDate = null;
                  selectedMonth = '${months[now.month - 1]} ${now.year}';
                }
              });
              fetchTimeLogs();
            },
            onMonthChanged: (DateTime picked) {
              const months = [
                'January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'
              ];
              setState(() {
                selectedDate = picked;
                selectedMonth = _isSpecificDate
                    ? '${months[picked.month - 1]} ${picked.day}, ${picked.year}'
                    : '${months[picked.month - 1]} ${picked.year}';
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
          SizedBox(height: mobile ? 12 : 16),

          // ── Table ──────────────────────────────────
          InternTimeLogTable(
            isDarkMode: isDarkMode,
            logs: filteredLogs,
            isSpecificDate: _isSpecificDate,
          ),
          const SizedBox(height: 12),

          // ── Legend ─────────────────────────────────
          InternTimeLogLegend(isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final bool isDarkMode;
  final String label;
  final String value;
  final Color? accentColor;

  const _StatCard({
    required this.isDarkMode,
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 600;
    final bg = isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF5F5F5);
    final labelColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final valueColor = accentColor ?? (isDarkMode ? Colors.white : Colors.black87);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 10 : 16,
        vertical: mobile ? 12 : 18,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: labelColor, fontSize: mobile ? 10 : 12),
          ),
          SizedBox(height: mobile ? 4 : 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor,
              fontSize: mobile ? 22 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}