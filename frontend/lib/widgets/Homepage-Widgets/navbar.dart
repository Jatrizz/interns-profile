import 'package:flutter/material.dart';
import 'package:interfaces/pages/home_page.dart';
import '../../pages/about_page.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  Size get preferredSize => const Size.fromHeight(95);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      toolbarHeight: 95,
      scrolledUnderElevation: 0,
      title: Padding(padding: EdgeInsetsGeometry.only(left: 50, right: 50),
        child: Row(
          children: [
            TextButton(onPressed: (){
              Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => HomePage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                ),
              );
            }, child: Text('Home', 
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 20,),
            TextButton(onPressed: (){
              Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => AboutPage(),
                transitionDuration: Duration.zero, // remove animation
                reverseTransitionDuration: Duration.zero,
              ),
            );
            }, child: Text('About', style: TextStyle(
              color: Colors.white,
              fontSize: 12,
                ),
              ),
            ),
            SizedBox(width: 20,),
            TextButton(onPressed: (){
            }, 
            child: Text('Contact',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
                ),
              ),
            ),
            Spacer(),
            TextButton(onPressed: (){}, child: Text('Login', 
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
                ),
              )
            ),
            SizedBox(width: 20,),
            TextButton(onPressed: (){}, child: Text('Register',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),)),
            SizedBox(width: 20,),
            IconButton(onPressed: (){}, icon: Icon(Icons.light_mode, color: Colors.white,
            size: 20,))
          ],
        ),
      )
    );
  }
}