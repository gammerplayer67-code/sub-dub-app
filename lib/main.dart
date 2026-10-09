import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: SubDubApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class SubDubApp extends StatefulWidget {
  const SubDubApp({super.key});

  @override
  State<SubDubApp> createState() => _SubDubAppState();
}

class _SubDubAppState extends State<SubDubApp> {
  String? videoPath;
  final TextEditingController srtController = TextEditingController();
  String selectedVoice = "သီဟ (ကျား - Thiha)";
  String selectedRatio = "9:16 (Shorts/TikTok)";
  double voiceSpeed = 1.0;
  bool isProcessing = false;
  String statusMessage = "အဆင်သင့်ဖြစ်ပါပြီ။ ဗီဒီယိုနှင့် SRT ထည့်သွင်းပါ။";

  final Map<String, String> edgeVoices = {
    "သီဟ (ကျား - Thiha)": "my-MM-ThihaNeural",
    "နီလာ (မ - Nilar)": "my-MM-NilarNeural"
  };

  Future<void> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        videoPath = result.files.single.path;
        statusMessage = "ဗီဒီယို ရွေးချယ်ပြီးပါပြီ။";
      });
    }
  }

  Future<void> startProcessing() async {
    if (videoPath == null) {
      setState(() => statusMessage = "❌ ဗီဒီယိုဖိုင် ရွေးပေးပါဦး။");
      return;
    }
    if (srtController.text.trim().isEmpty) {
      setState(() => statusMessage = "❌ SRT စာတန်း ရိုက်ထည့်ပေးပါ။");
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = "⏳ စတင်တွက်ချက်နေပါပြီ...";
    });

    try {
      Directory tempDir = await getTemporaryDirectory();
      String outPath = "${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4";

      // 1. Target resolution
      int targetW = 720;
      int targetH = 1280;
      if (selectedRatio.contains("16:9")) {
        targetW = 1280;
        targetH = 720;
      } else if (selectedRatio.contains("1:1")) {
        targetW = 1080;
        targetH = 1080;
      }

      setState(() => statusMessage = "🚀 ဖုန်း CPU ဖြင့် ဗီဒီယို Render စတင်နေပါသည်...");

      // 2. FFmpeg processing on phone CPU
      String ffmpegCmd = "-y -i \"$videoPath\" "
          "-vf \"scale=$targetW:$targetH:force_original_aspect_ratio=decrease,pad=$targetW:$targetH:(ow-iw)/2:(oh-ih)/2\" "
          "-c:v libx264 -preset ultrafast -crf 26 -c:a aac -b:a 128k \"$outPath\"";

      await FFmpegKit.executeAsync(ffmpegCmd, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          setState(() {
            isProcessing = false;
            statusMessage = "✅ ဖန်တီးမှု အောင်မြင်ပါသည်!\nသိမ်းဆည်းထားသောနေရာ:\n$outPath";
          });
        } else {
          setState(() {
            isProcessing = false;
            statusMessage = "❌ Render လုပ်ရာတွင် အမှားဖြစ်သွားပါသည်။";
          });
        }
      });
    } catch (e) {
      setState(() {
        isProcessing = false;
        statusMessage = "❌ Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎬 Sub & Dub Engine (Phone CPU)"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: isProcessing ? null : pickVideo,
              icon: const Icon(Icons.video_file),
              label: Text(videoPath == null ? "၁။ ဗီဒီယို ရွေးချယ်ပါ" : "ဗီဒီယို ရွေးပြီးပါပြီ"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: srtController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "၂။ SRT Format စာတန်းများ ထည့်ရန်",
                hintText: "1\n00:00:00,000 --> 00:00:04,000\nမင်္ဂလာပါ ခင်ဗျာ။",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedVoice,
              decoration: const InputDecoration(labelText: "အသံ ရွေးချယ်ရန်", border: OutlineInputBorder()),
              items: edgeVoices.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (val) => setState(() => selectedVoice = val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRatio,
              decoration: const InputDecoration(labelText: "ဗီဒီယို ဆိုဒ်", border: OutlineInputBorder()),
              items: ["9:16 (Shorts/TikTok)", "16:9 (YouTube/Facebook)", "1:1 (Square/Instagram)"]
                  .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => setState(() => selectedRatio = val!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isProcessing ? null : startProcessing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("🚀 ဗီဒီယို ဖန်တီးမည် (Render Video)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: Text(statusMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
