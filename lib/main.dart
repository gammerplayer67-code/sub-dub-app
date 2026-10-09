import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🎬 All IN ONE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const MainTabScreen(),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🎬 ALL IN ONE",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4F46E5),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amberAccent,
          tabs: const [
            Tab(icon: Icon(Icons.movie_creation), text: "Movie Dubbing"),
            Tab(icon: Icon(Icons.menu_book), text: "ပုံပြင် ဗီဒီယို"),
            Tab(icon: Icon(Icons.video_camera_back), text: "Movie Recap"),
            Tab(icon: Icon(Icons.text_snippet), text: "SRT Prompt"),
            Tab(icon: Icon(Icons.history), text: "မှတ်တမ်း (History)"),
            Tab(icon: Icon(Icons.admin_panel_settings), text: "Admin"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CreatorFormView(modeType: 0),
          CreatorFormView(modeType: 1),
          CreatorFormView(modeType: 2),
          SrtPromptView(),
          HistoryView(),
          AdminDashboardView(),
        ],
      ),
    );
  }
}

class CreatorFormView extends StatefulWidget {
  final int modeType;
  const CreatorFormView({super.key, required this.modeType});

  @override
  State<CreatorFormView> createState() => _CreatorFormViewState();
}

class _CreatorFormViewState extends State<CreatorFormView> {
  String? videoPath;
  String? bgmPath;
  String? logoPath;

  String voiceMode = "အသံတစ်မျိုးတည်း သုံးမည်";
  String selectedVoice = "ချောင် ပရိုလေး";
  String maleVoice = "ချောင် ပရိုလေး";
  String femaleVoice = "ခင်ဝင့်ဝါ";

  String subLinesMode = "၁ ကြောင်း (1 Line)";
  String selectedFont = "KoZ033Uni-Bold.ttf";
  String selectedColor = "အဝါရောင် (အနက်ဘောင်)";
  String selectedSize = "9:16 (Shorts/TikTok)";

  String colorFilter = "ပုံမှန် (Normal)";
  double colorIntensity = 100;
  String videoEffect = "မသုံးပါ (None)";
  double effectIntensity = 50;

  double customZoom = 1.0;
  double cropTop = 11;
  double cropBottom = 16;
  double cropLeft = 5;
  double cropRight = 5;

  double subPosition = 80;
  double fontSize = 46;
  double blurSize = 55;
  double voiceSpeed = 1.0;
  double voiceVolume = 1.4;
  double freezeThreshold = 50;

  bool addSubs = true;
  bool flipVideo = true;
  bool blurBg = true;

  double logoSize = 18;
  double logoX = 0;
  double logoY = 14;

  final TextEditingController srtController = TextEditingController();
  bool isProcessing = false;
  String statusMessage = "ℹ SRT စာတန်းများကို ထည့်သွင်းပြီး စတင်ဖန်တီးနိုင်ပါသည်။";

  final List<String> allVoices = ["ချောင် ပရိုလေး", "သီဟ (ကျား - Thiha)", "တိုင်းကျော်", "နီလာ (မ - Nilar)", "ဂွမ်းပုံ", "ခင်ဝင့်ဝါ"];
  final List<String> maleVoices = ["ချောင် ပရိုလေး", "သီဟ (ကျား - Thiha)", "တိုင်းကျော်"];
  final List<String> femaleVoices = ["နီလာ (မ - Nilar)", "ဂွမ်းပုံ", "ခင်ဝင့်ဝါ"];

  Future<void> pickFile(int type) async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      type: type == 1 ? FileType.video : (type == 2 ? FileType.audio : FileType.image),
    );
    if (res != null && res.files.single.path != null) {
      setState(() {
        if (type == 1) videoPath = res.files.single.path;
        if (type == 2) bgmPath = res.files.single.path;
        if (type == 3) logoPath = res.files.single.path;
      });
    }
  }

  void handleGenerate() async {
    if (videoPath == null) {
      setState(() => statusMessage = "❌ ဗီဒီယိုဖိုင် တင်ပေးပါ။");
      return;
    }
    if (srtController.text.trim().isEmpty) {
      setState(() => statusMessage = "❌ SRT စာတန်း ရိုက်ထည့်ပေးရန် လိုအပ်ပါသည်။");
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = "⏳ စတင်တွက်ချက်နေပါပြီ...";
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isProcessing = false;
      statusMessage = "✅ စမ်းသပ်မှု အောင်မြင်ပါသည်။ (Render Engine Ready)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: Color(0xFF3B82F6), width: 4)),
            ),
            child: Text(
              statusMessage,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
            ),
          ),
          const SizedBox(height: 12),

          // File Select Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => pickFile(1),
                  icon: const Icon(Icons.video_collection),
                  label: Text(videoPath == null ? "၁။ ဗီဒီယို ရွေးရန်" : "ဗီဒီယို ရွေးပြီး"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => pickFile(2),
                  icon: const Icon(Icons.music_note),
                  label: Text(bgmPath == null ? "BGM ရွေးရန်" : "BGM ရွေးပြီး"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Voice Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🎙️ စကားပြော ပုံစံ (Voice Mode)", style: TextStyle(fontWeight: FontWeight.bold)),
                  RadioListTile<String>(
                    dense: true,
                    title: const Text("အသံတစ်မျိုးတည်း သုံးမည်"),
                    value: "အသံတစ်မျိုးတည်း သုံးမည်",
                    groupValue: voiceMode,
                    onChanged: (v) => setState(() => voiceMode = v!),
                  ),
                  RadioListTile<String>(
                    dense: true,
                    title: const Text("ကျား/မ စုံတွဲအသံ သုံးမည်"),
                    value: "ကျား/မ စုံတွဲအသံ သုံးမည်",
                    groupValue: voiceMode,
                    onChanged: (v) => setState(() => voiceMode = v!),
                  ),
                  if (voiceMode == "အသံတစ်မျိုးတည်း သုံးမည်")
                    DropdownButtonFormField<String>(
                      value: selectedVoice,
                      decoration: const InputDecoration(labelText: "အသံ ရွေးချယ်ရန်"),
                      items: allVoices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => selectedVoice = v!),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: maleVoice,
                            decoration: const InputDecoration(labelText: "ကျား အသံ"),
                            items: maleVoices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                            onChanged: (v) => setState(() => maleVoice = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: femaleVoice,
                            decoration: const InputDecoration(labelText: "မ အသံ"),
                            items: femaleVoices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                            onChanged: (v) => setState(() => femaleVoice = v!),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // SRT Editor
          TextField(
            controller: srtController,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "၂။ SRT Editor (စာတန်းများ ထည့်ရန်)",
              hintText: "1\n00:00:00,000 --> 00:00:05,000\n[M] မင်္ဂလာပါ ခင်ဗျာ။",
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle and Video Layout Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSize,
                    decoration: const InputDecoration(labelText: "📐 ဗီဒီယို ဆိုဒ်"),
                    items: ["9:16 (Shorts/TikTok)", "16:9 (YouTube/Facebook)", "1:1 (Square/Instagram)", "4:3 (Classic TV)", "3:4 (Portrait)", "21:9 (Cinematic)"]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => selectedSize = v!),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedColor,
                    decoration: const InputDecoration(labelText: "🎨 စာတန်း အရောင်"),
                    items: ["အဝါရောင် (အနက်ဘောင်)", "အနီရောင် (အဖြူဘောင်)", "အဖြူရောင် (အပြာဘောင်)"]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => selectedColor = v!),
                  ),
                  Row(
                    children: [
                      Checkbox(value: addSubs, onChanged: (v) => setState(() => addSubs = v!)),
                      const Text("စာတန်းထိုးမည်"),
                      const Spacer(),
                      Checkbox(value: flipVideo, onChanged: (v) => setState(() => flipVideo = v!)),
                      const Text("ဘယ်/ညာ လှန်မည်"),
                      const Spacer(),
                      Checkbox(value: blurBg, onChanged: (v) => setState(() => blurBg = v!)),
                      const Text("Blur မည်"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Sliders Accordion
          ExpansionTile(
            title: const Text("✂️ Video Crop & Zoom (ပြင်ဆင်ချက်များ)"),
            children: [
              Text("Zoom: ${customZoom.toStringAsFixed(2)}x"),
              Slider(value: customZoom, min: 1.0, max: 3.0, onChanged: (v) => setState(() => customZoom = v)),
              Text("Crop Top: ${cropTop.toInt()}%"),
              Slider(value: cropTop, min: 0, max: 50, onChanged: (v) => setState(() => cropTop = v)),
              Text("Crop Bottom: ${cropBottom.toInt()}%"),
              Slider(value: cropBottom, min: 0, max: 50, onChanged: (v) => setState(() => cropBottom = v)),
            ],
          ),

          ExpansionTile(
            title: const Text("🎛️ Audio Speed & Volume"),
            children: [
              Text("အသံ မြန်နှုန်း: ${voiceSpeed.toStringAsFixed(1)}x"),
              Slider(value: voiceSpeed, min: 0.5, max: 2.0, onChanged: (v) => setState(() => voiceSpeed = v)),
              Text("အသံ အတိုးအကျယ်: ${voiceVolume.toStringAsFixed(1)}x"),
              Slider(value: voiceVolume, min: 0.5, max: 3.0, onChanged: (v) => setState(() => voiceVolume = v)),
            ],
          ),
          const SizedBox(height: 14),

          ElevatedButton(
            onPressed: isProcessing ? null : handleGenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("🚀 ၃။ ဖန်တီးမည် (Generate)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class SrtPromptView extends StatelessWidget {
  const SrtPromptView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📝 Pro Prompts များ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              title: Text("Movie Recap Standard Prompt"),
              subtitle: Text("ဇာတ်လမ်းအကျဉ်းများကို စိတ်လှုပ်ရှားဖွယ် မြန်မာစကားပြော ပြောင်းလဲရန် Prompt"),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("ဖန်တီးထားသော မှတ်တမ်း ဗီဒီယိုများ မရှိသေးပါ။"),
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("🛡️ Admin Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: "အသုံးပြုသူ အမည် (Username)", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          const TextField(decoration: InputDecoration(labelText: "စကားဝှက် (Password)", border: OutlineInputBorder())),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            child: const Text("အကောင့် သိမ်းမည်"),
          ),
        ],
      ),
    );
  }
}
