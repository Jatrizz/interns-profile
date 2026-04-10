import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardOverviewPage extends StatefulWidget {
  final String username;
  const DashboardOverviewPage({super.key, required this.username});

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  bool isDarkMode = true;
  int totalInterns = 0;
  int newInterns = 0;
  int totalSchools = 0;
  List<dynamic> admins = [];
  List<Map<String, dynamic>> schoolStats = [];
  String recentActivity = "";
  late Timer _timer;
  String _currentTime = "";
  DateTime _currentDate = DateTime.now();
  DateTime _calendarDate = DateTime.now();

  // Mock data for bar chart - interns per year per school
  final List<Map<String, dynamic>> mockYearlyStats = [
    {'year': '2022', 'PLSP': 5, 'CMDI': 3, 'LSPU': 2, 'OTHERS': 1},
    {'year': '2023', 'PLSP': 7, 'CMDI': 4, 'LSPU': 3, 'OTHERS': 2},
    {'year': '2024', 'PLSP': 9, 'CMDI': 5, 'LSPU': 4, 'OTHERS': 3},
    {'year': '2025', 'PLSP': 7, 'CMDI': 3, 'LSPU': 2, 'OTHERS': 1},
    {'year': '2026', 'PLSP': 7, 'CMDI': 3, 'LSPU': 2, 'OTHERS': 0},
  ];

  final List<Color> schoolColors = [
    const Color(0xFF00BFFF),
    const Color(0xFF7B61FF),
    const Color(0xFF00D084),
    const Color(0xFFFF6B6B),
  ];

  final List<String> schools = ['PLSP', 'CMDI', 'LSPU', 'OTHERS'];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    //fetchDashboardData();
    fetchAdmins();
    fetchSchoolStats();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      _currentDate = now;
    });
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8080/dashboard?username=${widget.username}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalInterns = data['total_interns'];
          newInterns = data['new_interns'];
          totalSchools = data['total_schools'];
        });
      }
    } catch (e) {
      print('Error fetching dashboard: $e');
    }
  }

  Future<void> fetchAdmins() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/admins'),
      );
      if (response.statusCode == 200) {
        setState(() {
          admins = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching admins: $e');
    }
  }

  Future<void> fetchSchoolStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/school-stats'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          schoolStats = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      print('Error fetching school stats: $e');
    }
  }

  void _previousMonth() {
    setState(() {
      _calendarDate = DateTime(_calendarDate.year, _calendarDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _calendarDate = DateTime(_calendarDate.year, _calendarDate.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchBar(),
                              const SizedBox(height: 20),
                              _buildWelcomeCard(),
                              const SizedBox(height: 20),
                              _buildStatsCards(),
                              const SizedBox(height: 20),
                              _buildBarChart(),
                              const SizedBox(height: 20),
                              _buildRecentActivity(),
                            ],
                          ),
                        ),
                      ),
                      _buildRightPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 65,
      color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF0F0F0),
      child: Column(
        children: [
          const SizedBox(height: 15),
          // Logo at top of sidebar
          Image.asset(
            'assets/images/logo.png',
            width: 36,
            height: 36,
            errorBuilder: (c, e, s) => Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF00BFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.circle, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 15),
          _buildSidebarIcon(Icons.grid_view, true, tooltip: 'Dashboard'),
          const SizedBox(height: 10),
          _buildSidebarIcon(Icons.person_outline, false, tooltip: 'Interns'),
          const SizedBox(height: 10),
          _buildSidebarIcon(
            Icons.groups_outlined,
            false,
            tooltip: 'Our Team',
            onTap: () => _showTeamDialog(context),
          ),
          const Spacer(),
          _buildSidebarIcon(Icons.logout, false, tooltip: 'Logout'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon(
    IconData icon,
    bool isActive, {
    String? tooltip,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? (isDarkMode ? Colors.grey[700] : Colors.grey[300])
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDarkMode ? Colors.white : Colors.black54,
            size: 22,
          ),
        ),
      ),
    );
  }

  // 3. Team dialog showing developer cards
  void _showTeamDialog(BuildContext context) {
    final team = [
      {
        'name': 'Lester Manzanero',
        'role': 'Frontend Developer',
        'icon': Icons.web,
        'color': const Color(0xFF00BFFF),
      },
      {
        'name': 'Janna Pujeda',
        'role': 'Full-stack Developer',
        'icon': Icons.code,
        'color': const Color(0xFF7B61FF),
      },
      {
        'name': 'Nathaniel Velasco',
        'role': 'Backend Developer',
        'icon': Icons.storage,
        'color': const Color(0xFF00D084),
      },
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDarkMode ? const Color(0xFF242424) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meet the Team',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'The people behind Internshit',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: team.map((member) {
                  return Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: (member['color'] as Color).withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: member['color'] as Color,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          member['icon'] as IconData,
                          color: member['color'] as Color,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        member['name'] as String,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        member['role'] as String,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Color(0xFF00BFFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Fixed top bar with bigger logo aligned properly
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF0F0F0),
      child: Row(
        children: [
          const Spacer(),
          Text(
            "Hi, ${widget.username}",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () => setState(() => isDarkMode = !isDarkMode),
            child: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDarkMode ? Colors.grey : Colors.grey[600],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey : Colors.grey[600],
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, ${widget.username.split(' ')[0]}!",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Welcome to your dashboard. Manage your interns efficiently.",
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _currentTime,
              style: TextStyle(
                color: const Color(0xFF00BFFF),
                fontSize: 42,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono',
                letterSpacing: 6,
                shadows: isDarkMode
                    ? [
                        Shadow(
                          color: const Color(0xFF00BFFF).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Justified text on stat cards
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard("No. of New Interns", newInterns.toString()),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            "Total No. of Interns",
            totalInterns.toString(),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard("No. of Schools", totalSchools.toString()),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        // 5. Center justified
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 6. Fixed bar chart with yearly data per school
  Widget _buildBarChart() {
    final schools = ['PLSP', 'CMDI', 'LSPU', 'OTHERS'];
    final schoolColors = [
      const Color(0xFF00BFFF),
      const Color(0xFF7B61FF),
      const Color(0xFF00D084),
      const Color(0xFFFF6B6B),
    ];

    int maxCount = 0;
    for (var year in mockYearlyStats) {
      for (var school in schools) {
        final val = year[school] as int;
        if (val > maxCount) maxCount = val;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interns per Year by School",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          // Legend
          Wrap(
            spacing: 15,
            children: List.generate(schools.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: schoolColors[i],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    schools[i],
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (i) => Text(
                      "${((maxCount / 5) * (5 - i)).round()}",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Bars
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: mockYearlyStats.map((yearData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Grouped bars for each school
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(schools.length, (si) {
                              final count = yearData[schools[si]] as int;
                              final barHeight = maxCount > 0
                                  ? (count / maxCount) * 170.0
                                  : 0.0;
                              return Container(
                                width: 12,
                                height: barHeight,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: schoolColors[si],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    topRight: Radius.circular(3),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            yearData['year'] as String,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey
                                  : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent activity",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            recentActivity.isEmpty ? "No recent activity" : recentActivity,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      width: 300,
      color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendar(),
          const SizedBox(height: 20),
          _buildAdminsList(),
        ],
      ),
    );
  }

  // 1. Fixed clickable calendar with month navigation
  Widget _buildCalendar() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _calendarDate.year,
      _calendarDate.month,
    );
    final firstDayOfMonth = DateTime(
      _calendarDate.year,
      _calendarDate.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final monthName = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][_calendarDate.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$monthName ${_calendarDate.year}",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Row(
              children: [
                // 1. Clickable previous month button
                GestureDetector(
                  onTap: _previousMonth,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                // 1. Clickable next month button
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat']
              .map(
                (day) => Text(
                  day,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 5),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox();
            final day = index - firstWeekday + 1;
            final isToday =
                day == _currentDate.day &&
                _calendarDate.month == _currentDate.month &&
                _calendarDate.year == _currentDate.year;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF00BFFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "$day",
                style: TextStyle(
                  color: isToday
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.black),
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdminsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Admins",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF2E2E2E)
                : const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: admins.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    "No admins found",
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: admins.length,
                  separatorBuilder: (_, __) => Divider(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      child: Text(
                        "${index + 1}. ${admins[index]['username']}",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
