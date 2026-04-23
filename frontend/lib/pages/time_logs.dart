import 'package:flutter/material.dart';
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

  String selectedMonth = 'April 2026';
  String selectedStatus = 'All';
  String selectedWeek = 'All Weeks';

  int currentPage = 1;
  int entriesPerPage = 8;

  bool _isDefaultView = true;

  List<Map<String, dynamic>> allLogs = [];
  List<Map<String, dynamic>> filteredLogs = [];

  @override
  void initState() {
    super.initState();
    fetchOverviewStats();
    fetchInterns();
    fetchTodayLogs();
  }

  Future<void> fetchOverviewStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/timelogs/overview'),
      );
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
      print('Error fetching overview stats: $e');
    }
  }

  Future<void> fetchInterns() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/interns/names'),
      );
      debugPrint('>>> interns/names status: ${response.statusCode}');
      debugPrint('>>> interns/names body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          internNames = data.map((e) => e.toString()).toList();
          totalInterns = internNames.length;
          debugPrint('>>> internNames: $internNames');
        });
      }
    } catch (e) {
      debugPrint('>>> Error fetching interns: $e');
    }
  }

  Future<void> fetchTodayLogs() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/timelogs/today'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allLogs = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _isDefaultView = true;
          applyFilters();
        });
      }
    } catch (e) {
      debugPrint('>>> Error fetching today logs: $e');
    }
  }

  Future<void> fetchLogsForIntern(String name) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8080/timelogs/intern?name=${Uri.encodeComponent(name)}'),
      );
      debugPrint('>>> timelogs/intern status: ${response.statusCode}');
      debugPrint('>>> timelogs/intern body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allLogs = data.map((e) => Map<String, dynamic>.from(e)).toList();
          applyFilters();
        });
      }
    } catch (e) {
      debugPrint('>>> Error fetching logs: $e');
      setState(() {
        allLogs = [];
        applyFilters();
      });
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> result = List.from(allLogs);
    if (selectedStatus != 'All') {
      result = result.where((log) => log['status'] == selectedStatus).toList();
    }
    setState(() {
      filteredLogs = result;
      currentPage = 1;
    });
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
                            color:
                                widget.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TimeLogsSearchBar(
                          isDarkMode: widget.isDarkMode,
                          searchQuery: searchQuery,
                          suggestions: filteredInternNames,
                          onChanged: (val) => setState(() => searchQuery = val),
                          onSuggestionSelected: (name) {
                            setState(() {
                              selectedIntern = name;
                              searchQuery = '';
                              _isDefaultView = false;
                            });
                            fetchLogsForIntern(name);
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
                          internNames: ['All Interns', ...filteredInternNames],
                          selectedIntern: selectedIntern ?? 'All Interns',
                          onChanged: (val) {
                            if (val != null) {
                              if (val == 'All Interns') {
                                setState(() {
                                  selectedIntern = 'All Interns';
                                  _isDefaultView = true;
                                });
                                fetchTodayLogs();
                              } else {
                                setState(() {
                                  selectedIntern = val;
                                  _isDefaultView = false;
                                });
                                fetchLogsForIntern(val);
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
                          onMonthChanged: (val) =>
                              setState(() => selectedMonth = val),
                          onStatusChanged: (val) {
                            setState(() => selectedStatus = val);
                            applyFilters();
                          },
                          onWeekChanged: (val) =>
                              setState(() => selectedWeek = val),
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
