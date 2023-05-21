import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FlutterSpeech(),
    );
  }
}

class FlutterSpeech extends StatefulWidget {
  const FlutterSpeech({super.key});

  @override
  State<FlutterSpeech> createState() => _FlutterSpeechState();
}

class _FlutterSpeechState extends State<FlutterSpeech> {
  stt.SpeechToText? _speechToText;
  bool _isListening = false;
  String _cmd = 'Tap the Button to Start Speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.white,
        title: Text(
          'Flutter Voice',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(microseconds: 2000),
        endRadius: 75.0,
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        child: FloatingActionButton(
          onPressed: () => _listen(),
          child: Icon(_isListening ? Icons.mic : Icons.mic_off),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "Confidence : ${(_confidence * 100.0).toStringAsFixed(2)}",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
                  child: TextHighlight(
                    text: _cmd,
                    words: _hwords,
                    textStyle: const TextStyle(
                      fontSize: 32.0,
                      wordSpacing: 2.0,
                      letterSpacing: 2.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final Map<String, HighlightedWord> _hwords = {};

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText!.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speechToText!.listen(
          onResult: (val) => setState(() {
            _cmd = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText!.stop();
    }
  }
}
