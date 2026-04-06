import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  final int interns;
  final int schools;
  final int programs;

  const StatsSection({
    super.key,
    required this.interns,
    required this.schools,
    required this.programs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: SizedBox(
        height: 350,
        width: 1100,
        child: Column(
          children: [
            Text('Statistics', style: TextStyle(
              fontSize: 30,
              color: Colors.white,
            )),
            SizedBox(height: 5),
            Text(
              'Empowering organizations to manage their interns efficiently and effectively.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            SizedBox(
              width: 1100,
              height: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildStat('$interns', 'Interns'),
                  divider(),
                  buildStat('$schools', 'Schools'),
                  divider(),
                  buildStat('$programs', 'Programs'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildStat(String value, String label) {
    return SizedBox(
      width: 100,
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 40, color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 20, color: Colors.white)),
        ],
      ),
    );
  }

  Widget divider() {
    return Container(
      height: 160,
      width: 1.5,
      color: Colors.white,
    );
  }
}
