import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class SortOptions {
  static const az = "A-Z";
  static const za = "Z-A";
  static const idAsc = "ID-ASC";
  static const idDesc = "ID-DESC";
}

class InternsList extends StatefulWidget {
  final bool isDarkMode;
  final Function(dynamic intern) onViewProfile;

  const InternsList({
    super.key,
    required this.isDarkMode,
    required this.onViewProfile,
  });

  @override
  State<InternsList> createState() => _InternsListState();
}

class _InternsListState extends State<InternsList> {
  List interns = [];
  List filteredInterns = [];
  String sortType = SortOptions.idAsc;
  final searchController = TextEditingController();
  Timer? _refreshTimer;

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
      final response = await http.get(Uri.parse("$_baseUrl/interns"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            interns = data;

            // preserve current filtered state if searching
            if (searchController.text.isEmpty) {
              filteredInterns = List.from(data);
            } else {
              filteredInterns = interns.where((intern) {
                final fullName =
                    "${intern['first_name']} ${intern['last_name']}"
                        .toLowerCase();
                return fullName.contains(searchController.text.toLowerCase());
              }).toList();
            }

            sortInterns(sortType, refresh: false);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          interns = [];
          filteredInterns = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fetch interns error: $e')),
        );
      }
    }
  }

  Future<void> deleteIntern(String idNumber) async {
    try {
      final uri = Uri.parse("$_baseUrl/delete-intern?id=$idNumber");
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await fetchInterns();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${data['message']} (${data['id_number']})")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: ${response.body}")),
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
          style:
              TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          "Are you sure you want to delete ${intern['first_name']} ${intern['last_name']}?",
          style:
              TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
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
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void searchIntern(String value) {
    final query = value.toLowerCase();

    setState(() {
      filteredInterns = interns.where((intern) {
        final fullName =
            "${intern['first_name']} ${intern['last_name']}".toLowerCase();

        final idNumber = intern['id_number'].toString().toLowerCase();

        return fullName.contains(query) || idNumber.contains(query);
      }).toList();

      sortInterns(sortType, refresh: false);
    });
  }

  void sortInterns(String type, {bool refresh = true}) {
    if (refresh) sortType = type;

    int parseId(dynamic value) {
      final cleaned = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }

    filteredInterns = List.from(filteredInterns)
      ..sort((a, b) {
        final nameA = "${a['first_name']} ${a['last_name']}".toLowerCase();
        final nameB = "${b['first_name']} ${b['last_name']}".toLowerCase();

        final idA = parseId(a['id_number']);
        final idB = parseId(b['id_number']);

        switch (type) {
          case "A-Z":
            return nameA.compareTo(nameB);
          case "Z-A":
            return nameB.compareTo(nameA);
          case "ID-ASC":
            return idA.compareTo(idB);
          case "ID-DESC":
            return idB.compareTo(idA);
          default:
            return 0;
        }
      });

    if (refresh) setState(() {});
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  Widget buildCard(dynamic intern) {
    final photo = _photoProvider(intern);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color.fromARGB(255, 55, 54, 54)
            : const Color.fromARGB(255, 240, 240, 240),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: widget.isDarkMode
              ? const Color.fromARGB(255, 85, 85, 85)
              : const Color.fromARGB(255, 111, 111, 111),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                if (value == "delete") confirmDelete(intern);
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
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage: photo,
            child: photo == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(height: 10),
          Text(
            "${intern['first_name']} ${intern['last_name']}",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey : Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            intern['id_number'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                color: widget.isDarkMode ? Colors.white : Colors.black,
                size: 15,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  intern['program'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                Icons.apartment_outlined,
                color: widget.isDarkMode ? Colors.white : Colors.black,
                size: 15,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  intern['school'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                Icons.phone_callback_outlined,
                color: widget.isDarkMode ? Colors.white : Colors.black,
                size: 15,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  intern['phone_number'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(5)),
                  ),
                ),
              ),
              onPressed: () => widget.onViewProfile(intern),
              child: const Text(
                "VIEW PROFILE",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      color: widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interns Profile",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode
                  ? Colors.white
                  : const Color.fromARGB(250, 0, 0, 0),
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
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  controller: searchController,
                  onChanged: searchIntern,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: widget.isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFF0F0F0),
                    prefixIcon: Icon(
                      Icons.search,
                      color: widget.isDarkMode
                          ? Colors.grey[500]
                          : Colors.grey[400],
                    ),
                    hintText: "Search Intern...",
                    hintStyle: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.grey[500]
                          : Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: widget.isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: widget.isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: widget.isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFFDDDDDD),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sortType,
                    dropdownColor: widget.isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFF0F0F0),
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
                      DropdownMenuItem(
                        value: "ID-ASC",
                        child: Text(
                          "ID (↑)",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white
                                : const Color.fromARGB(137, 0, 0, 0),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "ID-DESC",
                        child: Text(
                          "ID (↓)",
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
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          _getCrossAxisCount(constraints.maxWidth);
                      return GridView.builder(
                        itemCount: filteredInterns.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          mainAxisExtent: 370, // FIXED HEIGHT — no overflow
                        ),
                        itemBuilder: (context, index) =>
                            buildCard(filteredInterns[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
