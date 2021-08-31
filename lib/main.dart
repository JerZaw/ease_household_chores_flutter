import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      home: PersonInfo(),
  ));
}

  class PersonInfo extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              'House Member Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black12,
          ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(30,40,30,40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  'IMIĘ i NAZWISKO'
              ),
              SizedBox(height: 10),
              Text(
                  'Jerzy Zawieja',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 30),
              Text(
                  'CZĘŚĆ DOMU DO SPRZĄTNIĘCIA'
              ),
              SizedBox(height: 10),
              Text(
                'kuchnia',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 30),
              Text(
                  'DEADLINE'
              ),
              SizedBox(height: 10),
              Text(
                '3 dni',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 30),
              Text(
                  'MAŁE PRACE ZROBIONE W TYM TYGODNIU'
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ZMYWARKA',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'ŚMIECI',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'KOTY',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }