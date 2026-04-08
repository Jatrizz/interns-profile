import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 700,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Create your Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight(600),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: 400,
                child: Row(
                  children: [
                    Container(
                      width: 195,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.grey],
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
                            'First Name',
                            style: TextStyle(
                              color: const Color.fromARGB(209, 255, 255, 255),
                              fontSize: 12,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 195,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.grey],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 3,
                      ),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          label: Text(
                            'Last Name',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    label: Text(
                      'School',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey],
                    begin: Alignment.bottomLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    label: Text(
                      'Program',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    label: Text(
                      'Email',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    label: Text(
                      'Password',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      const Color.fromARGB(255, 2, 55, 230),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 400,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    children: [
                      TextSpan(
                        text: 'By creating an account, you agree to our ',
                      ),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
