import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/excerpt_model.dart';

class AddExcerptScreen extends StatefulWidget {
  const AddExcerptScreen({Key? key}) : super(key: key);

  @override
  State<AddExcerptScreen> createState() => _AddExcerptScreenState();
}

class _AddExcerptScreenState extends State<AddExcerptScreen> {
  File? _imageFile;
  String _extractedText = '';
  bool _isProcessing = false;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isProcessing = true;
        });

        await _performOCR();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 실패: $e')),
        );
      }
    }
  }

  Future<void> _performOCR() async {
    if (_imageFile == null) return;

    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
      final InputImage inputImage = InputImage.fromFile(_imageFile!);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
        _textController.text = _extractedText;
        _isProcessing = false;
      });

      await textRecognizer.close();

      if (_extractedText.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('텍스트를 인식하지 못했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR 처리 실패: $e')),
        );
      }
    }
  }

  Future<String> _saveImagePermanently() async {
    if (_imageFile == null) throw Exception('이미지가 없습니다');

    final appDir = await getApplicationDocumentsDirectory();
    final excerptDir = Directory('${appDir.path}/excerpts');
    if (!await excerptDir.exists()) {
      await excerptDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = path.join(excerptDir.path, fileName);
    await _imageFile!.copy(savedPath);

    return savedPath;
  }

  Future<void> _saveExcerpt() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 사진을 촬영해주세요')),
      );
      return;
    }

    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('텍스트가 비어있습니다')),
      );
      return;
    }

    try {
      setState(() => _isProcessing = true);

      final savedImagePath = await _saveImagePermanently();
      final pageNumber = int.tryParse(_pageController.text.trim());

      final excerpt = Excerpt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: savedImagePath,
        extractedText: _extractedText,
        editedText: _textController.text.trim(),
        pageNumber: pageNumber,
        dateAdded: DateTime.now(),
      );

      if (mounted) {
        Navigator.of(context).pop(excerpt);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('발췌문 저장 실패: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사진 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFC),
      appBar: AppBar(
        title: const Text('발췌문 추가'),
        backgroundColor: const Color(0xFF757472),
        foregroundColor: Colors.white,
        actions: [
          if (_imageFile != null && !_isProcessing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveExcerpt,
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6D6D6D)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'OCR 처리 중...',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 이미지 표시 영역
                  if (_imageFile != null)
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEDEDED)),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 64,
                              color: Color(0xFF757472),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '사진을 촬영하거나 선택하세요',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 사진 촬영 버튼
                  ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(_imageFile == null ? '사진 촬영/선택' : '다시 촬영/선택'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D6D6D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 페이지 번호 입력
                  TextField(
                    controller: _pageController,
                    decoration: const InputDecoration(
                      labelText: '페이지 번호 (선택)',
                      labelStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),

                  // 추출된 텍스트 편집 영역
                  const Text(
                    '추출된 텍스트 (수정 가능)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'OCR로 추출된 텍스트가 여기에 표시됩니다',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 10,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),

                  // 안내 텍스트
                  if (_extractedText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEDEDED)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF6D6D6D), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '텍스트를 수정한 후 상단의 체크 버튼을 눌러 저장하세요',
                              style: TextStyle(color: Colors.black54, fontSize: 12),
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
