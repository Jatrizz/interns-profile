import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InternsList extends StatefulWidget {
  final bool isDarkMode;

  const InternsList({super.key, required this.isDarkMode});

  @override
  State<InternsList> createState() => _InternsListState();
}

class _InternsListState extends State<InternsList> {
  List interns = [];
  List filteredInterns = [];
  String sortType = "A-Z";
  final searchController = TextEditingController();

  static const String _baseUrl = "http://localhost:8080";

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  ImageProvider? _photoProvider(dynamic intern) {
    final photo = intern['photo']?.toString() ?? '';
    if (photo.isEmpty) return null;
    if (photo.startsWith('http')) return NetworkImage(photo);
    final cleaned = photo.startsWith('/') ? photo.substring(1) : photo;
    return NetworkImage('$_baseUrl/$cleaned');
  }

  Future<void> fetchInterns() async {
    try {
      final response =
          await http.get(Uri.parse("$_baseUrl/interns"));

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

  Future<void> deleteIntern(String idNumber) async {
    try {
      final uri = Uri.parse(
        "$_baseUrl/delete-intern?id=$idNumber",
      );

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await fetchInterns();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${data['message']} (${data['id_number']})",
            ),
          ),
        );
      } else {
        final msg = response.body;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $msg")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  void confirmDelete(dynamic intern) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            widget.isDarkMode ? const Color(0xFF2B2B2B) : Colors.white,
        title: Text(
          "Delete Intern",
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          "Are you sure you want to delete ${intern['first_name']} ${intern['last_name']}?",
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteIntern(intern['id_number'].toString());
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
      String nameA = "${a['first_name']} ${a['last_name']}".toLowerCase();
      String nameB = "${b['first_name']} ${b['last_name']}".toLowerCase();
      return type == "A-Z" ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });

    if (refresh) setState(() {});
  }

  Widget buildCard(dynamic intern) {
    final photo = _photoProvider(intern);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.black54 : Colors.white,
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
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: widget.isDarkMode ? Colors.white : Colors.black54,
              ),
              color: widget.isDarkMode ? Colors.black54 : Colors.white,
              onSelected: (value) {
                if (value == "delete") {
                  confirmDelete(intern);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "delete",
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        "Delete",
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[300],
            backgroundImage: photo,
            child: photo == null
                ? const Icon(Icons.person, size: 35)
                : null,
          ),
          const SizedBox(height: 15),
          Text(
            "${intern['first_name']} ${intern['last_name']}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey : Colors.black,
            ),
          ),
          Text(
            intern['id_number'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            intern['program'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            intern['school'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            intern['phone_number'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode ? Colors.white : Colors.black54,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: const ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.blue),
              ),
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
    return Container(
      padding: const EdgeInsets.all(25),
      color: widget.isDarkMode
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF7F7F7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interns Profile",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "This is the total student that is chenelin chenelin.",
            style: TextStyle(
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  style: const TextStyle(
                      color: Color.fromARGB(223, 255, 255, 255)),
                  controller: searchController,
                  onChanged: searchIntern,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: widget.isDarkMode
                        ? const Color.fromARGB(255, 68, 67, 67)
                        : Colors.white,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: "Search Intern...",
                    hintStyle: TextStyle(
                      color: widget.isDarkMode ? Colors.grey : Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? const Color.fromARGB(255, 64, 64, 64)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sortType,
                    dropdownColor: widget.isDarkMode
                        ? const Color.fromARGB(255, 64, 64, 64)
                        : Colors.white,
                    items: [
                      DropdownMenuItem(
                        value: "A-Z",
                        child: Text(
                          "Sort A-Z",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Z-A",
                        child: Text(
                          "Sort Z-A",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) => sortInterns(value!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: filteredInterns.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 70,
                          color: widget.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[400],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "No interns registered at the moment",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    itemCount: filteredInterns.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) =>
                        buildCard(filteredInterns[index]),
                  ),
          ),
        ],
      ),
    );
  }
}