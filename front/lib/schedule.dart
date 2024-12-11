import 'package:flutter/material.dart';

class MedicationSchedule extends StatelessWidget {
  const MedicationSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 201, 201),
      appBar: AppBar(
        title: const Text("약 스케줄"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView( // 스크롤 가능하도록 추가
        child: Padding( // 양쪽에 패딩 추가
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // 좌우 패딩 16
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 20),
              // const SizedBox(height: 20),
              const ScheduleSection(title: "아침" ),
              const SizedBox(height: 20),
              const ScheduleSection(title: "점심"),
              const SizedBox(height: 20),
              const ScheduleSection(title: "저녁"),
              const SizedBox(height: 20), // 추가 여백
              const ScheduleSection(title: "추가 섹션"), // 테스트용 섹션 추가 가능
            ],
          ),
        ),
      )
    );
  }
}

class ScheduleSection extends StatelessWidget {
  final String title;

  const ScheduleSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFbddefc),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}
