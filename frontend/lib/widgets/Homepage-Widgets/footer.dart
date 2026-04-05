import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(padding: EdgeInsetsGeometry.only(left: 65, right: 65),
              child: Row(
                children: [
                  Icon(Icons.copyright, color: Colors.grey, size: 15,),
                  SizedBox(width: 2,),
                  Text('2026 Internshit. All Rights Reserved.', 
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      ),
                    ),
                  Spacer(),
                  Text('Privacy Policy | Terms of Service', 
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
              ),
            )
          ],
        )
      )
    );
  }
}