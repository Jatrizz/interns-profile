import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
                padding: EdgeInsetsGeometry.only(right: 0, left: 0),
                  child: SizedBox(
                    height: 350,
                    width: 1100,
                    child: Column(
                      children: [
                        Text('Statistics', style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text('Empowering organizations to manage their interns efficiently and effectively.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 1100,
                          height: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('{#}',
                                    style: TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      ),
                                    ),
                                    Text('Interns', style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),)
                                  ],

                                ),
                              ),
                              Container(
                                height: 160,
                                width: 1.5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('5+', style: TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      ),
                                    ),
                                    Text('Schools', style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),)
                                  ],
                                ),
                              ),
                              Container(
                                height: 160,
                                width: 1.5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 150,
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('{#}', style: TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      ),
                                    ),
                                    Text('Programs', style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),)
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            }