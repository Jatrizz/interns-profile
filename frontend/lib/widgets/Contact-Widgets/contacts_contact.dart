import 'package:flutter/material.dart';

class ContactsContact extends StatelessWidget {
  const ContactsContact({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 130, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get in touch with us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight(500),
                  ),
                ),
                Text(
                  'Have questions or need help? We`d love to\nhear from you.',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'Our Location San Pablo City, Philippines',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.mark_email_read, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text(
                      'Email Us support@internshit.com',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.call, size: 20, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'Call us 09123456789',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 200),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 109, 108, 108),
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 46, 46, 46),
                            const Color.fromARGB(255, 103, 103, 103),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 3,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text(
                            'Name',
                            style: TextStyle(
                              color: const Color.fromARGB(209, 255, 255, 255),
                            ),
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 46, 46, 46),
                            const Color.fromARGB(255, 103, 103, 103),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 3,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text(
                            'Email',
                            style: TextStyle(
                              color: const Color.fromARGB(209, 255, 255, 255),
                            ),
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 46, 46, 46),
                            const Color.fromARGB(255, 103, 103, 103),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 3,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text(
                            'Message',
                            style: TextStyle(
                              color: const Color.fromARGB(209, 255, 255, 255),
                            ),
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 400,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 88, 167, 231),
                            const Color.fromARGB(255, 65, 39, 235),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Center(
                              child: Text(
                                'Send Now!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
