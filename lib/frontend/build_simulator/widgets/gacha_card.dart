import 'package:flutter/material.dart';

class GachaCard extends StatelessWidget {
  const GachaCard({
    required this.gacha1Stat1,
    required this.gacha1Stat2,
    required this.gacha1Stat3,
    required this.gacha2Stat1,
    required this.gacha2Stat2,
    required this.gacha2Stat3,
    required this.gacha3Stat1,
    required this.gacha3Stat2,
    required this.gacha3Stat3,
    required this.onGacha1Stat1Changed,
    required this.onGacha1Stat2Changed,
    required this.onGacha1Stat3Changed,
    required this.onGacha2Stat1Changed,
    required this.onGacha2Stat2Changed,
    required this.onGacha2Stat3Changed,
    required this.onGacha3Stat1Changed,
    required this.onGacha3Stat2Changed,
    required this.onGacha3Stat3Changed,
    super.key,
  });

  final String gacha1Stat1;
  final String gacha1Stat2;
  final String gacha1Stat3;
  final String gacha2Stat1;
  final String gacha2Stat2;
  final String gacha2Stat3;
  final String gacha3Stat1;
  final String gacha3Stat2;
  final String gacha3Stat3;
  final ValueChanged<String> onGacha1Stat1Changed;
  final ValueChanged<String> onGacha1Stat2Changed;
  final ValueChanged<String> onGacha1Stat3Changed;
  final ValueChanged<String> onGacha2Stat1Changed;
  final ValueChanged<String> onGacha2Stat2Changed;
  final ValueChanged<String> onGacha2Stat3Changed;
  final ValueChanged<String> onGacha3Stat1Changed;
  final ValueChanged<String> onGacha3Stat2Changed;
  final ValueChanged<String> onGacha3Stat3Changed;

  @override
  Widget build(BuildContext context) {
    return const Text('Gacha settings');
  }
}
