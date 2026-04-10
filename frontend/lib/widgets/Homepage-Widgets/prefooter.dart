import 'package:flutter/material.dart';

class PreFooter extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 150),
        child: SizedBox(
          height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 150,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/logo.png', height: 50, width: 50,
                                    fit: BoxFit.cover,),
                                    Text('Internshit', style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight(500),
                                      color: Colors.white,
                                    ),)
                                  ],
                                ),   
                              ],
                            ),
                            Padding(padding: EdgeInsetsGeometry.only(left: 50, right: 2,),
                            child:Text('A simple and efficient management system Contact built for organizations to track and manage their interns.', 
                                  style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromRGBO(255, 255, 255, 0.815)
                                ),
                              )
                            ),
                          ],
                        ),
                      ),
                        SizedBox(
                          height: 150,
                          width: 200,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(padding: EdgeInsetsGeometry.only(top: 15, bottom: 14),
                            child:Text('Follow Us', style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight(500),
                            ),),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                              width: 25,
                              height: 85,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.facebook, size: 20, color: Colors.grey),
                                  Image.asset('assets/images/instagram.png', width: 18, height: 18, color: Colors.grey, ),
                                  Image.asset('assets/images/linkedin.png', width: 18, height: 18, color: Colors.grey,)
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 85,
                                  width: 60,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Internshit', style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),),
                                      Text('Internshit', style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),),
                                      Text('Internshit', style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),)
                                    ],
                                  ),
                                )
                              ]
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 17,),
                              Text('Contact', style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight(500)
                              ),),
                          SizedBox(height: 14,),
                            SizedBox(
                              height: 80,
                              width: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Email@company.com', style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),),
                                Text('09123456789', style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),),
                                Text('San Pablo City, Laguna', style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }