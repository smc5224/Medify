import 'package:flutter/material.dart';
import 'savedMedicines.dart'; // 찾은 약 모음 페이지
import 'schedule.dart'; // 약 스케줄 페이지
import 'homePage.dart'; // 홈 페이지

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1; // 초기 선택된 페이지: 홈 페이지

  // 페이지 리스트
  final List<Widget> _pages = [
    const SavedMedicinesPage(), // 0: 찾은 약 모음 페이지
    const HomePage(), // 1: 홈 페이지
    const MedicationSchedule(), // 2: 약 스케줄 페이지
  ];

  // 네비게이션 버튼 클릭 시
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 페이지 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex], // 선택된 페이지 표시
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomAppBar(
            color: Colors.white, // footer 배경색
            child: Container(
              height: 30, // Footer 높이 (최소로 줄임)
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildNavItem(Icons.medical_services, "약 모음", 0, _selectedIndex == 0),
                  buildNavItem(Icons.home, "홈", 1, _selectedIndex == 1),
                  buildNavItem(Icons.calendar_today, "스케줄", 2, _selectedIndex == 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavItem(IconData icon, String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF0a7eeb) : Colors.grey,
            size: 32, // 아이콘 크기 더 줄임
          ),
          const SizedBox(height: 4), // 아이콘과 텍스트 사이 여백 줄임
          Text(
            label,
            style: TextStyle(
              fontSize: 10, // 텍스트 크기 더 줄임
              color: isSelected ? const Color(0xFF0a7eeb) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  } 
}
