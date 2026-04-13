import 'package:flutter/material.dart';

class AdminsList extends StatelessWidget {
  final bool isDarkMode;
  final List<dynamic> admins;

  const AdminsList({super.key, required this.isDarkMode, required this.admins});

  @override
  Widget build(BuildContext context) {
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
                        "${index + 1}. ${admins[index]['first_name']} ${admins[index]['last_name']}",
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
