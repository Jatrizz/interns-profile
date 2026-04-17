import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interfaces/pages/contact_page.dart';
import 'package:interfaces/widgets/Dashboard-Widgets/sidebar.dart';
import 'package:interfaces/widgets/Dashboard-Widgets/top_bar.dart';

class InternsList extends StatefulWidget {
  const InternsList({super.key});

  @override
  State<InternsList> createState() => _InternsListState();
}

class _InternsListState extends State<InternsList> {
  bool isDarkMode = false;
  String firstName = "Admin";

  List interns = [];
  List filteredInterns = [];

  String sortType = "A-Z";

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  Future<void> fetchInterns() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:8080/interns"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          interns = data;
          filteredInterns = data;
        });
      }
    } catch (e) {
      setState(() {
        interns = [];
        filteredInterns = [];
      });
    }
  }

  void searchIntern(String value) {
    setState(() {
      filteredInterns = interns.where((intern) {
        final fullName =
            "${intern['first_name']} ${intern['last_name']}".toLowerCase();

        return fullName.contains(value.toLowerCase());
      }).toList();

      sortInterns(sortType, refresh: false);
    });
  }

  void sortInterns(String type, {bool refresh = true}) {
    if (refresh) sortType = type;

    filteredInterns.sort((a, b) {
      String nameA =
          "${a['first_name']} ${a['last_name']}".toLowerCase();

      String nameB =
          "${b['first_name']} ${b['last_name']}".toLowerCase();

      return type == "A-Z"
          ? nameA.compareTo(nameB)
          : nameB.compareTo(nameA);
    });

    if (refresh) {
      setState(() {});
    }
  }

  void onToggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void onLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ContactPage()),
    );
  }

  Widget buildCard(dynamic intern) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2B2B2B)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 35,
            child: Icon(Icons.person, size: 35),
          ),

          const SizedBox(height: 15),

          Text(
            "${intern['first_name']} ${intern['last_name']}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            intern['program'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            intern['school'] ?? '',
            style: const TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 5),

          Text(
            intern['phone_number'] ?? '',
            style: const TextStyle(fontSize: 12),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("VIEW PROFILE"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            isDarkMode: isDarkMode,
            onLogout: onLogout,
          ),

          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDarkMode: isDarkMode,
                  firstName: firstName,
                  onToggleDarkMode: onToggleDarkMode,
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    color: isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF7F7F7),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Interns Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "This is the total student that is chenelin chenelin.",
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            SizedBox(
                              width: 260,
                              child: TextField(
                                controller:
                                    searchController,
                                onChanged:
                                    searchIntern,
                                decoration:
                                    InputDecoration(
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? const Color(
                                          0xFF2B2B2B)
                                      : Colors.white,
                                  prefixIcon:
                                      const Icon(
                                          Icons.search),
                                  hintText:
                                      "Search Intern...",
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                30),
                                    borderSide:
                                        BorderSide
                                            .none,
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 15,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: isDarkMode
                                    ? const Color(
                                        0xFF2B2B2B)
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            30),
                              ),
                              child:
                                  DropdownButtonHideUnderline(
                                child:
                                    DropdownButton<
                                        String>(
                                  value: sortType,
                                  items: const [
                                    DropdownMenuItem(
                                      value:
                                          "A-Z",
                                      child: Text(
                                          "Sort A-Z"),
                                    ),
                                    DropdownMenuItem(
                                      value:
                                          "Z-A",
                                      child: Text(
                                          "Sort Z-A"),
                                    ),
                                  ],
                                  onChanged:
                                      (value) {
                                    sortInterns(
                                        value!);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        Expanded(
                          child: filteredInterns
                                  .isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .people_outline,
                                        size: 70,
                                        color: isDarkMode
                                            ? Colors.grey[
                                                500]
                                            : Colors.grey[
                                                400],
                                      ),
                                      const SizedBox(
                                          height:
                                              15),
                                      Text(
                                        "No interns registered at the moment",
                                        style:
                                            TextStyle(
                                          fontSize:
                                              20,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          color: isDarkMode
                                              ? Colors.grey[
                                                  400]
                                              : Colors.grey[
                                                  600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  itemCount:
                                      filteredInterns
                                          .length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        4,
                                    crossAxisSpacing:
                                        20,
                                    mainAxisSpacing:
                                        20,
                                    childAspectRatio:
                                        0.75,
                                  ),
                                  itemBuilder:
                                      (context,
                                              index) =>
                                          buildCard(
                                    filteredInterns[
                                        index],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}