

import 'package:flutter/material.dart';

class TeamSection extends StatelessWidget{
  const TeamSection({super.key});
  @override

  Widget build (BuildContext context){
    return Padding(padding: EdgeInsetsGeometry.symmetric(
      horizontal: 200),
      child: Column(
        children: [
          SizedBox(height: 80,),
          Text('Meet the Team', style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight(600),
            ),
          ),
          Text('The people behind Internshit.', style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            ),
          ),
          SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    child: Image.asset('../../../assets/images/profile_placeholder.webp', height: 200,),
                  ),
                  SizedBox(height: 10,),
                  Text('Lester John Manzanero', style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight(600),
                    ),
                  ),
                  Text('Pogi lang', style: TextStyle(
                    color: Colors.white,
                    fontSize: 14
                  ),)
                ]
              ),
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    child: Image.asset('../../../assets/images/profile_placeholder.webp', height: 200,),
                  ),
                  SizedBox(height: 10,),
                  Text('Janna Tricia Pujeda', style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight(600),
                    ),
                  ),
                  Text('Fullstack Developer', style: TextStyle(
                    color: Colors.white,
                    fontSize: 14
                  ),)
                ],
              ),
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(20),
                    child: Image.asset('../../../assets/images/profile_placeholder.webp', height: 200,),
                  ),
                  SizedBox(height: 10,),
                  Text('Nathaniel Velasco', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight(600),
                    fontSize: 15,
                  ),),
                  Text('Backend Developer', style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),)
                ],
              )
            ],
          ),
        ],
      )
    );
  }
}