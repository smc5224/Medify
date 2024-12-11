import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homePage.dart'; // 홈 페이지를 위한 import

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String? _prediction;
  double? _confidence;

  final ImagePicker _picker = ImagePicker();

  // 이미지 선택 (갤러리 또는 카메라)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }
  
  String _convertToKorean(String prediction) {
  switch (prediction) {
    case "Tylenol":
      return "타이레놀";
    case "Fish Oil":
      return "오메가3";
    default:
      return prediction; // 변환이 없는 경우 원래 값을 반환
  }
}
  // 서버에 이미지 업로드 및 예측 요청
  Future<void> _predictImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://ba1f-180-71-27-250.ngrok-free.app/predict'); // Flask 서버 주소
      final request = http.MultipartRequest('POST', url);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _imageBytes!,
        filename: 'uploaded_image.jpg',
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);

        setState(() {
          _prediction = json['predicted_class'];
          _confidence = json['confidence'];
        });

        // Convert prediction value
        String koreanPrediction = _convertToKorean(_prediction!);

        // 결과 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              prediction: koreanPrediction,
              confidence: _confidence!,
            ),
          ),
        );
      } else {
        throw Exception('Failed to get prediction');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예측 요청 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 이미지 미리보기
            if (_imageBytes != null)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  // borderRadius: BorderRadius.circular(10),
                ),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('이미지를 선택하세요.')),
              ),
            const SizedBox(height: 20),
            // 이미지 선택 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('카메라'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.grey; // hover 시 배경색
                        }
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.grey[300]; // 눌렀을 때 배경색
                        }
                        return null; // 기본 상태 유지
                      },
                    ),
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black, width: 0.5), // 테두리 추가
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text('갤러리'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.grey; // hover 시 배경색
                        }
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.grey[300]; // 눌렀을 때 배경색
                        }
                        return null; // 기본 상태 유지
                      },
                    ),
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black, width: 0.5), // 테두리 추가
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // 추가 여백을 넣어 예측 버튼을 아래로 내림
            // 예측 버튼
            ElevatedButton(
              onPressed: _imageBytes == null || _isLoading ? null : _predictImage,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                    _imageBytes == null
                        ? '이미지를 선택해주세요' // 이미지가 선택되지 않은 경우 표시할 텍스트
                        : 'Medify', // 이미지가 선택된 경우 표시할 텍스트
                  ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.white; // 비활성화 상태에서 배경색
                    }
                    return const Color(0xFFBEA2FF); // 기본 배경색
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey; // 비활성화 상태에서 글자색
                    }
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.black; // hover 시 글자색
                    }
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.grey[800]; // 눌렀을 때 글자색
                    }
                    return Colors.white; // 기본 글자색
                  },
                ),
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.white; // hover 시 배경색
                    }
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.grey[300]; // 눌렀을 때 배경색
                    }
                    return Colors.grey; // 기본 상태 유지
                  },
                ),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black, width: 0.5), // 테두리 추가
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  final String prediction;
  final double confidence;

  const ResultPage({super.key, required this.prediction, required this.confidence});

  @override
  _ResultPageState createState() => _ResultPageState();
}

// 약 사진 저장 및 동적 표시
String _getMedicineImage(String prediction) {
  switch (prediction) {
    case "타이레놀":
      return 'assets/Tylenol.png'; // 타이레놀 이미지 경로
    case "오메가3":
      return 'assets/FishOil.png'; // 오메가-3 이미지 경로
    default:
      return 'assets/default.png'; // 기본 이미지 경로 (예: 이미지가 없는 경우)
  }
}

// 약 사진 저장 및 동적 표시
String _getMedicine(String prediction) {
  if (prediction == null) return "카테고리 정보 없음";
  switch (prediction) {
    case "타이레놀":
      return "해열진통제"; // 타이레놀 이미지 경로
    case "오메가3":
      return "비타민"; // 오메가-3 이미지 경로
    default:
      return "약 정보 없음"; // 기본 이미지 경로 (예: 이미지가 없는 경우)
  }
}


class _ResultPageState extends State<ResultPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 데이터 세트로 각 약품에 따라 다른 내용을 정의
  final Map<String, List<String>> _medicineContents = {
    "타이레놀": [
      "감기로 인한 발열 및 동통(통증), 두통, 신경통, 근육통, 생리통, 염좌통(삔 통증)",
      "만 12세 이상 소아 및 성인:1회 1~2정씩 1일 3-4회 (4-6시간 마다) 필요시 복용한다.\n"
          "1일 최대 4그램 (8정)을 초과하여 복용하지 않는다.\n"
          "이 약은 가능한 최단기간동안 최소 유효용량으로 복용한다.",
      "1. 경고\n"
          "1) 매일 세잔 이상 정기적으로 술을 마시는 사람이 복용할 경우 간손상이 유발될 수 있다.\n"
          "2) 일일 최대 용량(4000mg)을 초과하여 복용할 경우 간손상을 일으킬 수 있다.\n"
          "3) 소아 및 고령자는 최소 필요량을 복용하고 이상반응에 유의한다.\n"
          "4) 다른 소염진통제와 함께 복용하는 것은 피한다.\n"
          "2. 저장상의 주의사항\n"
          "1) 밀폐용기, 실온(1~30도)보관\n"
          "2) 어린이의 손이 닿지 않는 곳에 보관한다.",
      "1) 의약품을 싱크대, 변기, 하수구에 버리지 마세요.\n"
          "2) 일부 지역에서는 오래된 약들을 모아서 폐기하도록 안내하며,\n"
          "약국이나 지역사회 차원에서 의약품 폐기 프로그램을 운영합니다.\n"
          "3) 이용 가능한 프로그램이 없는 경우에는 용기를 통째로 바깥에 있는 쓰레기통에 버립니다."
    ],
    "오메가3": [
      "혈소판 응집과 염증반응 감소, 혈중 중성지방의 농도 감소, 심박수와 혈압 강하",

      "통상 초회용량은 1일 2g(2캡슐)이며, 필요시 1일 4g까지 증량할 수 있다.\n"
      "1일 1회 또는 2회 투여한다.",

      "1. 다음 환자에는 투여하지 말 것\n"
      "1) 이 약의 구성성분에 과민반응을 나타내는 환자\n"
      "2) 18세 미만의 소아\n"
      "2. 다음 환자에는 신중히 투여할 것2. 다음 환자에는 신중히 투여할 것 접기\n"
      "1) 심한 외상 및 수술 등 출혈의 고위험 상태에 있는 환자\n"
      "2) 간기능 장애환자\n"
      "3) 생선에 과민성 또는 알러지가 있는 환자",

      "1) 어린이의 손이 닿지 않는 곳에 보관한다.\n"
      "2) 다른 용기에 바꾸어 넣는 것은 사고원인이 되거나 품질유지 면에서 바람직하지 않으므로 주의한다."
      
    ],
  };

  final List<String> _titles = ["효능", "용법/용량", "주의사항", "폐기 방법"];
  List<String> _currentContents = [];

  @override
  void initState() {
    super.initState();
    // prediction에 따라 내용을 설정
    _currentContents = _medicineContents[widget.prediction] ?? ["정보를 찾을 수 없습니다."];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Medify Result', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 약 정보 카드
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // 약사진 섹션
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        _getMedicineImage(widget.prediction), // 이미지 경로 (여기서 파일명을 동적으로 설정 가능)
                        fit: BoxFit.cover, // 이미지를 꽉 채우도록 설정
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 약 정보 섹션
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F375),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.prediction,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getMedicine(widget.prediction), // 이 부분도 prediction에 따라 다르게 표시 가능
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 슬라이드 컨테이너
            Expanded(
              child: Column(
                children: [
                  // 점 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _titles.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? Colors.black : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 201, 201, 201),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _currentContents.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titles[index], // 제목 표시
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    _currentContents[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
