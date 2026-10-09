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
      title: '🎬 All IN ONE Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFFEC4899),
        ),
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
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              "ALL IN ONE STUDIO",
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8, fontSize: 19),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorWeight: 3.5,
          indicatorColor: Colors.amberAccent,
          tabs: const [
            Tab(icon: Icon(Icons.movie_creation_outlined), text: "Movie Dubbing"),
            Tab(icon: Icon(Icons.auto_stories_outlined), text: "ပုံပြင် ဗီဒီယို"),
            Tab(icon: Icon(Icons.video_library_outlined), text: "Movie Recap"),
            Tab(icon: Icon(Icons.psychology_alt_outlined), text: "SRT Prompts"),
            Tab(icon: Icon(Icons.history_toggle_off), text: "မှတ်တမ်း"),
            Tab(icon: Icon(Icons.admin_panel_settings_outlined), text: "Admin"),
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

  bool addSubs = true;
  bool flipVideo = true;
  bool blurBg = true;

  final TextEditingController srtController = TextEditingController();
  bool isProcessing = false;
  String statusMessage = "စတင်ဖန်တီးရန် ဗီဒီယိုနှင့် SRT စာတန်းများကို ထည့်သွင်းပါ။";

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
      setState(() => statusMessage = "❌ ဗီဒီယိုဖိုင် အရင်ရွေးချယ်ပေးပါ။");
      return;
    }
    if (srtController.text.trim().isEmpty) {
      setState(() => statusMessage = "❌ SRT စာတန်းများ ရိုက်ထည့်ပေးပါ။");
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = "🚀 AI စနစ်ဖြင့် ဗီဒီယိုအား စတင် Render လုပ်ဆောင်နေပါသည်...";
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isProcessing = false;
      statusMessage = "✅ ဗီဒီယိုဖန်တီးမှု အောင်မြင်စွာ ပြီးဆုံးပါပြီ။";
    });
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Color iconColor, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
              ],
            ),
            const Divider(height: 20, thickness: 0.8),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dynamic Status Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isProcessing 
                    ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isProcessing ? Icons.hourglass_top : Icons.info_outline,
                  color: isProcessing ? Colors.white : const Color(0xFF4F46E5),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isProcessing ? Colors.white : const Color(0xFF312E81),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // File Selectors
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => pickFile(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.video_file, color: Colors.white, size: 26),
                        const SizedBox(height: 4),
                        Text(videoPath == null ? "ဗီဒီယို ရွေးရန်" : "ဗီဒီယို ရွေးပြီး ✔", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => pickFile(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.music_note, color: Colors.white, size: 26),
                        const SizedBox(height: 4),
                        Text(bgmPath == null ? "BGM ရွေးရန်" : "BGM ရွေးပြီး ✔", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Voice Configuration
          _buildSectionCard(
            title: "စကားပြော ပုံစံ (Voice Settings)",
            icon: Icons.mic,
            iconColor: const Color(0xFF8B5CF6),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: "အသံတစ်မျိုးတည်း သုံးမည်", label: Text("တစ်ကိုယ်တော်")),
                  ButtonSegment(value: "ကျား/မ စုံတွဲအသံ သုံးမည်", label: Text("ကျား/မ စုံတွဲ")),
                ],
                selected: {voiceMode},
                onSelectionChanged: (set) => setState(() => voiceMode = set.first),
              ),
              const SizedBox(height: 12),
              if (voiceMode == "အသံတစ်မျိုးတည်း သုံးမည်")
                DropdownButtonFormField<String>(
                  value: selectedVoice,
                  decoration: InputDecoration(
                    labelText: "အသံ ရွေးချယ်ရန်",
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: allVoices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => selectedVoice = v!),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: maleVoice,
                        decoration: InputDecoration(labelText: "ကျား အသံ", filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        items: maleVoices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                        onChanged: (v) => setState(() => maleVoice = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: femaleVoice,
                        decoration: InputDecoration(labelText: "မ အသံ", filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        items: femaleVoices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                        onChanged: (v) => setState(() => femaleVoice = v!),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // SRT Text Editor
          _buildSectionCard(
            title: "SRT Editor (စာတန်း ရေးသားရန်)",
            icon: Icons.edit_note,
            iconColor: const Color(0xFFF59E0B),
            children: [
              TextField(
                controller: srtController,
                maxLines: 7,
                style: const TextStyle(fontSize: 14, height: 1.4),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  hintText: "1\n00:00:00,000 --> 00:00:05,000\n[M] မင်္ဂလာပါ ခင်ဗျာ။",
                ),
              ),
            ],
          ),

          // Styling & Video Specs
          _buildSectionCard(
            title: "ဗီဒီယို နှင့် စာတန်း ဒီဇိုင်း",
            icon: Icons.palette,
            iconColor: const Color(0xFFEC4899),
            children: [
              DropdownButtonFormField<String>(
                value: selectedSize,
                decoration: InputDecoration(labelText: "ဗီဒီယို ဆိုဒ်", filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ["9:16 (Shorts/TikTok)", "16:9 (YouTube/Facebook)", "1:1 (Square/Instagram)", "4:3 (Classic TV)", "3:4 (Portrait)", "21:9 (Cinematic)"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => selectedSize = v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedColor,
                decoration: InputDecoration(labelText: "စာတန်း အရောင်", filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ["အဝါရောင် (အနက်ဘောင်)", "အနီရောင် (အဖြူဘောင်)", "အဖြူရောင် (အပြာဘောင်)"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => selectedColor = v!),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: [
                  FilterChip(
                    label: const Text("စာတန်းထိုးမည်"),
                    selected: addSubs,
                    onSelected: (v) => setState(() => addSubs = v),
                    selectedColor: const Color(0xFFE0E7FF),
                  ),
                  FilterChip(
                    label: const Text("ဘယ်/ညာ လှန်မည်"),
                    selected: flipVideo,
                    onSelected: (v) => setState(() => flipVideo = v),
                    selectedColor: const Color(0xFFE0E7FF),
                  ),
                  FilterChip(
                    label: const Text("နောက်ခံ Blur"),
                    selected: blurBg,
                    onSelected: (v) => setState(() => blurBg = v),
                    selectedColor: const Color(0xFFE0E7FF),
                  ),
                ],
              ),
            ],
          ),

          // Tuning Sliders
          _buildSectionCard(
            title: "အသေးစိတ် အသံနှင့် ကင်မရာချိန်ညှိမှု",
            icon: Icons.tune,
            iconColor: const Color(0xFF06B6D4),
            children: [
              Text("အသံ မြန်နှုန်း: ${voiceSpeed.toStringAsFixed(1)}x", style: const TextStyle(fontWeight: FontWeight.w600)),
              Slider(value: voiceSpeed, min: 0.5, max: 2.0, activeColor: const Color(0xFF06B6D4), onChanged: (v) => setState(() => voiceSpeed = v)),
              Text("ဗီဒီယို Zoom: ${customZoom.toStringAsFixed(2)}x", style: const TextStyle(fontWeight: FontWeight.w600)),
              Slider(value: customZoom, min: 1.0, max: 3.0, activeColor: const Color(0xFF6366F1), onChanged: (v) => setState(() => customZoom = v)),
            ],
          ),

          // Generate Button
          Container(
            height: 56,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: isProcessing ? null : handleGenerate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rocket_launch, color: Colors.white),
                        SizedBox(width: 8),
                        Text("ဖန်တီးမည် (GENERATE)", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
            ),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPromptCard("🎬 Movie Recap Prompt", "အက်ရှင်ဇာတ်လမ်းများကို စိတ်လှုပ်ရှားဖွယ် ဇာတ်ပို့စကားအဖြစ် ပြောင်းလဲပေးသည့် Prompt"),
        _buildPromptCard("📚 ပုံပြင် / သုတရသ Prompt", "ကလေးပုံပြင်များနှင့် ဗဟုသုတရသ အကြောင်းအရာများကို နားထောင်ကောင်းအောင် ဖန်တီးပေးသည့် Prompt"),
        _buildPromptCard("🔥 TikTok Hook Prompt", "ဗီဒီယို အစပိုင်း ၃ စက္ကန့်အတွင်း လူစိတ်ဝင်စားမှု ရစေမည့် Caption ရေးနည်း Prompt"),
      ],
    );
  }

  Widget _buildPromptCard(String title, String desc) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.bolt, color: Color(0xFF4F46E5))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.copy_rounded, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_collection_outlined, size: 70, color: Colors.grey),
          SizedBox(height: 10),
          Text("ဖန်တီးထားသော ဗီဒီယိုမှတ်တမ်း မရှိသေးပါ။", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF312E81)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🛡️ User Control Panel", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("အသုံးပြုသူ အကောင့်များနှင့် ရက်သက်တမ်း စီမံခန့်ခွဲခြင်း", style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: "အသုံးပြုသူ အမည် (Username)", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: "စကားဝှက် (Password)", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("အကောင့် သိမ်းမည် / အသစ်ထည့်မည်"),
          ),
        ],
      ),
    );
  }
}
