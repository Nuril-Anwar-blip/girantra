import 'package:flutter/material.dart';
import '../../services/ai_research_service.dart';
import '../../widgets/seller_recommendation_card.dart';
import '../../ui/app_colors.dart';

class AiResearchScreen extends StatefulWidget {
  const AiResearchScreen({super.key});

  @override
  State<AiResearchScreen> createState() => _AiResearchScreenState();
}

class _AiResearchScreenState extends State<AiResearchScreen> {
  final _service = AiResearchService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  List<_ChatEntry> _messages = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  MarketStats? _stats;

  final List<Map<String, dynamic>> _chips = [
    {
      'icon': Icons.grass,
      'text': 'Pupuk termurah minggu ini',
      'category': 'fertilizer',
    },
    {
      'icon': Icons.star,
      'text': 'Penjual rating tertinggi',
      'category': 'reputation',
    },
    {
      'icon': Icons.eco,
      'text': 'Benih unggul harga terjangkau',
      'category': 'seeds',
    },
    {
      'icon': Icons.bakery_dining_sharp,
      'text': 'Sayuran organik murah',
      'category': 'produce',
    },
    {
      'icon': Icons.bar_chart,
      'text': 'Bandingkan harga pupuk NPK',
      'category': 'fertilizer',
    },
    {
      'icon': Icons.trending_up,
      'text': 'Produk terlaris bulan ini',
      'category': 'trending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await _service.fetchMarketStats();
    if (mounted) setState(() => _stats = stats);
  }

  void _addWelcomeMessage() {
    _messages.add(
      _ChatEntry.ai(
        message:
            'Halo! Saya asisten AI Girantra 👋\n\n'
            'Saya bisa membantu kamu menemukan **penjual terbaik dan termurah** '
            'berdasarkan analisis harga, rating, dan ulasan pembeli real-time.\n\n'
            'Mau cari produk apa hari ini?',
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add(_ChatEntry.user(message: trimmed));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final result = await _service.sendMessage(
        userMessage: trimmed,
        conversationHistory: _history,
      );

      // Simpan ke history untuk multi-turn
      _history.add({'role': 'user', 'content': trimmed});
      _history.add({'role': 'assistant', 'content': result.message});

      // Batasi history agar tidak terlalu panjang (hemat token)
      if (_history.length > 20) {
        _history = _history.sublist(_history.length - 20);
      }

      setState(() {
        _messages.add(
          _ChatEntry.ai(
            message: result.message,
            recommendations: result.recommendations,
            tip: result.tip,
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatEntry.ai(
            message:
                'Maaf, terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}. '
                'Pastikan OPENAI_API_KEY sudah diisi di file .env.',
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatStatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsBar(),
          _buildChips(),
          Expanded(child: _buildMessageList()),
          if (_isLoading) _buildTypingIndicator(),
          _buildInputRow(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 110,
      leading: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFF1B1B1B),
          size: 16,
        ),
        label: const Text(
          'Kembali',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Color(0xFF1B1B1B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF1D9E75),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asisten Riset Penjual',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B1B),
                  fontFamily: 'Montserrat',
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D9E75),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'AI Aktif',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1D9E75),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3DE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'AI Powered',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF3B6D11),
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _StatCard(
            value: _stats != null
                ? _formatStatNumber(_stats!.totalSellers)
                : '-',
            label: 'Penjual aktif',
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: _stats != null
                ? _formatStatNumber(_stats!.totalProducts)
                : '-',
            label: 'Produk',
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: _stats != null ? '${_stats!.avgRating} ⭐' : '-',
            label: 'Avg rating',
          ),
        ],
      ),
    );
  }

  // widget
  Widget _buildChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pertanyaan cepat:',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _chips.map((chip) {
                return GestureDetector(
                  onTap: () => _sendMessage(chip['text'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          chip['icon'] as IconData,
                          size: 16,
                          color: const Color(0xFF1D9E75),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          chip['text'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final entry = _messages[index];
        return entry.isUser
            ? _UserBubble(message: entry.message)
            : _AiBubble(
                message: entry.message,
                recommendations: entry.recommendations,
                tip: entry.tip,
              );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF1D9E75),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  hintText: 'Tanya tentang produk atau penjual...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontFamily: 'Montserrat',
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF1D9E75)),
                  ),
                ),
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_textController.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isLoading
                      ? Colors.grey[400]
                      : const Color(0xFF1D9E75),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatEntry {
  final bool isUser;
  final String message;
  final List<SellerRecommendation> recommendations;
  final String tip;

  _ChatEntry.user({required this.message})
    : isUser = true,
      recommendations = const [],
      tip = '';

  _ChatEntry.ai({
    required this.message,
    List<SellerRecommendation>? recommendations,
    String? tip,
  }) : isUser = false,
       recommendations = recommendations ?? const [],
       tip = tip ?? '';
}

class _UserBubble extends StatelessWidget {
  final String message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF1D9E75),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey[200],
            child: const Icon(
              Icons.person_outline,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final String message;
  final List<SellerRecommendation> recommendations;
  final String tip;

  const _AiBubble({
    required this.message,
    required this.recommendations,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar AI
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF1D9E75),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),

          // Bubble konten
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                  topLeft: Radius.circular(4),
                ),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teks pesan utama (parse **bold**)
                  _RichMessage(text: message),

                  // Kartu rekomendasi penjual
                  if (recommendations.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...recommendations.map(
                      (rec) => SellerRecommendationCard(recommendation: rec),
                    ),
                  ],

                  // Tip belanja
                  if (tip.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF1D9E75), width: 3),
                        ),
                      ),
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontFamily: 'Montserrat',
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RichMessage extends StatelessWidget {
  final String text;
  const _RichMessage({required this.text});

  List<TextSpan> _parse(String raw) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;

    for (final match in regex.allMatches(raw)) {
      if (match.start > last) {
        spans.add(TextSpan(text: raw.substring(last, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
      last = match.end;
    }
    if (last < raw.length) {
      spans.add(TextSpan(text: raw.substring(last)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1B1B1B),
          fontFamily: 'Montserrat',
          height: 1.55,
        ),
        children: _parse(text),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                color: Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7C7C7C),
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.15;
            final t = (_ctrl.value - delay).clamp(0.0, 1.0);
            final dy = t < 0.5 ? -4.0 * t : -4.0 * (1.0 - t);
            return Transform.translate(
              offset: Offset(0, dy),
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.grey[500],
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
