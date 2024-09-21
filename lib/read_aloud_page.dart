import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:translator/translator.dart';

class ReadAloudPage extends StatefulWidget {
  @override
  _ReadAloudPageState createState() => _ReadAloudPageState();
}

class _ReadAloudPageState extends State<ReadAloudPage> {
  FlutterTts flutterTts = FlutterTts();
  String _selectedLanguage = "English (US)";
  File? _image;
  String _recognizedText = "";

final Map<String, String> languageMap = {
  "English (US)": "en",
  "Spanish": "es",
  "French": "fr",
  "German": "de",
  "Chinese (Simplified)": "zh",
  "Urdu": "ur",
  "Arabic": "ar",
  "Italian": "it",
  "Japanese": "ja",
  "Korean": "ko",
  "Portuguese": "pt",
  "Russian": "ru",
  "Hindi": "hi",
  "Bengali": "bn",
  "Turkish": "tr",
  "Dutch": "nl",
  "Polish": "pl",
  "Swedish": "sv",
  "Greek": "el",
  "Czech": "cs",
  "Hungarian": "hu",
  "Thai": "th",
};


  Future<void> _translateAndSpeak(String originalText) async {
    String languageCode = languageMap[_selectedLanguage] ?? "en";
    String translatedText = await _translateText(originalText, languageCode);
    setState(() {
      _recognizedText = translatedText;
    });
    await _speak(translatedText, languageCode);
  }

  Future<String> _translateText(String text, String targetLanguage) async {
    final translator = GoogleTranslator();
    var translation = await translator.translate(text, to: targetLanguage);
    return translation.text;
  }

  Future<void> _speak(String text, String languageCode) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          _recognizeText(_image!);
        }
      });
    }
  }

  Future<void> _recognizeText(File image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    final visionText = await textDetector.processImage(inputImage);

    String recognizedText = visionText.text;
    await _translateAndSpeak(recognizedText);
  }

  Future<void> _readAloud() async {
    if (_recognizedText.isNotEmpty) {
      String languageCode = languageMap[_selectedLanguage] ?? "en";
      await _speak(_recognizedText, languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Textoice",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 1, 1, 89),
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explanatory Text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Capture, Translate, and Listen",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 1, 1, 89),
                ),
              ),
            ),

            SizedBox(height: 25,),
            // Language Selection Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Language",
                labelStyle: TextStyle(color: Color.fromARGB(255, 1, 1, 89)),
                prefixIcon: Icon(Icons.language, color: Color.fromARGB(255, 1, 1, 89)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color.fromARGB(255, 1, 1, 89)),
                ),
              ),
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              items: languageMap.keys.map<DropdownMenuItem<String>>((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              isExpanded: true,
            ),
            SizedBox(height: 20),
            // Buttons aligned horizontally
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _getImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 1, 1, 89),
                    padding: EdgeInsets.symmetric(horizontal: 23.0, vertical: 13.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text("Capture", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  onPressed: _readAloud,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 1, 1, 89),
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: Icon(Icons.volume_up, color: Colors.white),
                  label: Text("Read Aloud", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Display Selected Image
            _image == null
                ? Center(
                    child: Text(
                      "No image selected.",
                      style: TextStyle(color: Color.fromARGB(255, 1, 1, 89), fontSize: 18),
                    ),
                  )
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromARGB(255, 1, 1, 89)),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            // Display Recognized Text
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    _recognizedText.isNotEmpty
                        ? _recognizedText
                        : "No text recognized.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
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
