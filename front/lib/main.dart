import 'package:flutter/material.dart';
import 'splash_screen.dart'; // 로딩 화면
import 'main_navigation.dart'; // 네비게이션
import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled = true; // 레이아웃 경계 표시
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      title: 'Medify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // 초기 화면을 SplashScreen으로 설정
    );
  }
}
