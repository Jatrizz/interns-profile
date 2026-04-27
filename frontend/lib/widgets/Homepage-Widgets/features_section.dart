import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  final bool isDarkMode;
  const FeaturesSection({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            SizedBox(
              height: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Our Features',
                    style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 150,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 150,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.manage_accounts,
                                        size: 60,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                      Text(
                                        'Profile Management',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 150,
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 60, color: isDarkMode ? Colors.white : Colors.black87,),
                            Text(
                              'Search and Filter',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dashboard,
                              size: 60,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            Text(
                              'Dashboard Overview',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sort, size: 60, color: isDarkMode ? Colors.white : Colors.black87,),
                            Text(
                              'Sort and Organize',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.contact_page,
                              size: 60,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            Text(
                              'Contact Management',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
