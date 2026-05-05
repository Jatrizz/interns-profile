import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/TimeLogs-Widgets/time_logs_search_bar.dart';
import '../widgets/TimeLogs-Widgets/time_logs_intern_dropdown.dart';
import '../widgets/TimeLogs-Widgets/time_logs_overview_cards.dart';
import '../widgets/TimeLogs-Widgets/time_logs_filters.dart';
import '../widgets/TimeLogs-Widgets/time_logs_table.dart';
import '../widgets/TimeLogs-Widgets/time_logs_pagination.dart';
import '../widgets/TimeLogs-Widgets/time_logs_legend.dart';

class TimeLogsPage extends StatefulWidget {
  final String firstName;
  final bool isDarkMode;

  const TimeLogsPage({
    super.key,
    required this.firstName,
    required this.isDarkMode,
  });

  @override
  State<TimeLogsPage> createState() => _TimeLogsPageState();
}

class _TimeLogsPageState extends State<TimeLogsPage> {
  int totalInterns = 0;
  int presentToday = 0;
  int lateToday = 0;
  int absentToday = 0;

  List<String> internNames = [];
  String? selectedIntern;
  String searchQuery = '';
  bool _isDefaultView = true;

  String selectedStatus = 'All';
  String selectedWeek = 'All Weeks';

  int currentPage = 1;
  int entriesPerPage = 8;

  final _now = DateTime.now();
  late String selectedMonth;
  bool _isSpecificDate = true;
  late DateTime? selectedDate;

  List<Map<String, dynamic>> allLogs = [];
  List<Map<String, dynamic>> filteredLogs = [];

  late Timer _refreshTimer;
  bool _isFetching = false;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = _now;
    selectedMonth = '${_months[_now.month - 1]} ${_now.day}, ${_now.year}';

    fetchOverviewStats();
    fetchInterns();
    fetchTodayLogs(resetPage: true);

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted || _isFetching) return;
      _isFetching = true;
      fetchOverviewStats();
      if (_isDefaultView) {
        await fetchTodayLogs();
      } else if (selectedIntern != null && selectedIntern != 'All Interns') {
        await fetchLogsForIntern(selectedIntern!);
      }
      _isFetching = false;
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> fetchOverviewStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/timelogs/overview'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalInterns = data['total_interns'] ?? totalInterns;
          presentToday = data['present_today'] ?? presentToday;
          lateToday = data['late_today'] ?? lateToday;
          absentToday = data['absent_today'] ?? absentToday;
        });
      }
    } catch (e) {
      debugPrint('Error fetching overview stats: $e');
    }
  }

  Future<void> fetchInterns() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/interns/names'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          internNames = data.map((e) => e.toString()).toList();
          totalInterns = internNames.length;
        });
      }
    } catch (e) {
      debugPrint('>>> Error fetching interns: $e');
    }
  }

  Future<void> fetchTodayLogs({bool resetPage = false}) async {
    String url;
    if (_isSpecificDate && selectedDate != null) {
      final date = selectedDate!.toIso8601String().split('T')[0];
      url = 'http://127.0.0.1:8080/timelogs/today?date=$date';
    } else {
      final parsed = _parseSelectedMonth();
      url =
          'http://127.0.0.1:8080/timelogs/today?month=${parsed['month']}&year=${parsed['year']}';
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allLogs = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _isDefaultView = true;
          applyFilters(resetPage: resetPage);
        });
      }
    } catch (e) {
      debugPrint('>>> Error fetching today logs: $e');
    }
  }

  Future<void> fetchLogsForIntern(String name, {bool resetPage = false}) async {
    String url;
    if (_isSpecificDate && selectedDate != null) {
      final date = selectedDate!.toIso8601String().split('T')[0];
      url =
          'http://127.0.0.1:8080/timelogs/intern?name=${Uri.encodeComponent(name)}&date=$date';
    } else {
      final parsed = _parseSelectedMonth();
      url =
          'http://127.0.0.1:8080/timelogs/intern?name=${Uri.encodeComponent(name)}&month=${parsed['month']}&year=${parsed['year']}';
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allLogs = data.map((e) => Map<String, dynamic>.from(e)).toList();
          applyFilters(resetPage: resetPage);
        });
      }
    } catch (e) {
      debugPrint('>>> Error fetching logs: $e');
    }
  }

  void applyFilters({bool resetPage = false}) {
    List<Map<String, dynamic>> result = List.from(allLogs);

    if (selectedStatus != 'All') {
      result = result.where((log) {
        final status = log['status']?.toString().toLowerCase().trim() ?? '';
        switch (selectedStatus) {
          case 'Present':
            return status == 'on-time' || status == 'late';
          case 'On Time':
            return status == 'on-time';
          case 'Late':
            return status == 'late';
          case 'Absent':
            return status == 'absent';
          case 'Half Day':
            return status == 'half-day' ||
                status == 'halfday' ||
                status == 'half day';
          case 'Weekend':
            return status == 'weekend';
          default:
            return status == selectedStatus.toLowerCase().trim();
        }
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
      if (resetPage) currentPage = 1;
    });
  }

  Map<String, int> _parseSelectedMonth() {
    final parts = selectedMonth.split(' ');
    final monthIndex = _months.indexOf(parts[0]) + 1;
    final year = int.tryParse(parts[1]) ?? DateTime.now().year;
    return {'month': monthIndex, 'year': year};
  }

  List<Map<String, dynamic>> get paginatedLogs {
    final start = (currentPage - 1) * entriesPerPage;
    final end = (start + entriesPerPage).clamp(0, filteredLogs.length);
    return filteredLogs.sublist(start, end);
  }

  int get totalPages =>
      filteredLogs.isEmpty ? 1 : (filteredLogs.length / entriesPerPage).ceil();

  List<String> get filteredInternNames {
    if (searchQuery.isEmpty) return internNames;
    return internNames
        .where((name) => name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Logs',
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TimeLogsSearchBar(
                          isDarkMode: widget.isDarkMode,
                          searchQuery: searchQuery,
                          suggestions: filteredInternNames,
                          onChanged: (val) =>
                              setState(() => searchQuery = val),
                          onSuggestionSelected: (name) {
                            setState(() {
                              selectedIntern = name;
                              searchQuery = '';
                              _isDefaultView = false;
                            });
                            fetchLogsForIntern(name, resetPage: true);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Intern Name',
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TimeLogsInternDropdown(
                          isDarkMode: widget.isDarkMode,
                          internNames: [
                            'All Interns',
                            ...filteredInternNames
                          ],
                          selectedIntern: selectedIntern ?? 'All Interns',
                          onChanged: (val) {
                            if (val != null) {
                              if (val == 'All Interns') {
                                setState(() {
                                  selectedIntern = 'All Interns';
                                  _isDefaultView = true;
                                });
                                fetchTodayLogs(resetPage: true);
                              } else {
                                setState(() {
                                  selectedIntern = val;
                                  _isDefaultView = false;
                                });
                                fetchLogsForIntern(val, resetPage: true);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TimeLogsFilters(
                          isDarkMode: widget.isDarkMode,
                          selectedMonth: selectedMonth,
                          selectedStatus: selectedStatus,
                          selectedWeek: selectedWeek,
                          isSpecificDate: _isSpecificDate,
                          onToggleMode: (val) {
                            setState(() {
                              _isSpecificDate = val;
                              final now = DateTime.now();
                              if (val) {
                                selectedDate = now;
                                selectedMonth =
                                    '${_months[now.month - 1]} ${now.day}, ${now.year}';
                              } else {
                                selectedDate = null;
                                selectedMonth =
                                    '${_months[now.month - 1]} ${now.year}';
                              }
                            });
                            fetchTodayLogs(resetPage: true);
                          },
                          onMonthChanged: (DateTime picked) {
                            setState(() {
                              selectedDate = picked;
                              if (_isSpecificDate) {
                                selectedMonth =
                                    '${_months[picked.month - 1]} ${picked.day}, ${picked.year}';
                              } else {
                                selectedMonth =
                                    '${_months[picked.month - 1]} ${picked.year}';
                              }
                            });
                            if (_isDefaultView) {
                              fetchTodayLogs(resetPage: true);
                            } else if (selectedIntern != null &&
                                selectedIntern != 'All Interns') {
                              fetchLogsForIntern(selectedIntern!,
                                  resetPage: true);
                            }
                          },
                          onStatusChanged: (val) {
                            setState(() => selectedStatus = val);
                            applyFilters(resetPage: true);
                          },
                          onWeekChanged: (val) {
                            setState(() => selectedWeek = val);
                            applyFilters(resetPage: true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              TimeLogsOverviewCards(
                isDarkMode: widget.isDarkMode,
                totalInterns: totalInterns,
                presentToday: presentToday,
                lateToday: lateToday,
                absentToday: absentToday,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TimeLogsTable(
            isDarkMode: widget.isDarkMode,
            logs: paginatedLogs,
            showName: _isDefaultView,
          ),
          const SizedBox(height: 12),
          TimeLogsPagination(
            isDarkMode: widget.isDarkMode,
            currentPage: currentPage,
            totalPages: totalPages,
            totalEntries: filteredLogs.length,
            shownCount: paginatedLogs.length,
            onPageChanged: (page) => setState(() => currentPage = page),
          ),
          const SizedBox(height: 16),
          TimeLogsLegend(isDarkMode: widget.isDarkMode),
        ],
      ),
    );
  }
}