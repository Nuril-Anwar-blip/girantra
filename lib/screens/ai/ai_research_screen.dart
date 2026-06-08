import 'package:flutter/material.dart';
import '../../services/ai_research_service.dart';
import '../../ui/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Gira AI Research Screen
// ─────────────────────────────────────────────────────────────────────────────

class GiraAiScreen extends StatefulWidget {
  const GiraAiScreen({super.key});

  @override
  State<GiraAiScreen> createState() => _GiraAiScreenState();
}

class _GiraAiScreenState extends State<GiraAiScreen> {
  final _service = AiAssistantService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  List<AiMessage> _messages = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};

  // Quick prompt chips berdasarkan kategori
  final List<_QuickPrompt> _quickPrompts = [
    _QuickPrompt(
      icon: '🥗',
      text: 'Menu sehat minggu ini',
      category: 'menu',
    ),
    _QuickPrompt(
      icon: '🍳',
      text: 'Resep dari sayuran segar',
      category: 'recipe',
    ),
    _QuickPrompt(
      icon: '🌿',
      text: 'Cara menanam sayuran di rumah',
      category: 'farming',
    ),
    _QuickPrompt(
      icon: '💰',
      text: 'Rekomendasi belanja hemat',
      category: 'product',
    ),
    _QuickPrompt(
      icon: '🥦',
      text: 'Manfaat brokoli untuk kesehatan',
      category: 'nutrition',
    ),
    _QuickPrompt(
      icon: '🌾',
      text: 'Pupuk terbaik untuk padi',
      category: 'product',
    ),
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
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await _service.fetchMarketStats();
    if (mounted) setState(() => _stats = stats);
  }

  void _addWelcomeMessage() {
    _messages.add(
      AiMessage(
        role: 'assistant',
        content:
            'Halo! Aku **Gira**, asisten AI Girantra 🌿\n\n'
            'Aku bisa membantu kamu dengan:\n'
            '• 🛒 Rekomendasi produk segar terbaik\n'
            '• 🍳 Resep masakan dari bahan yang ada\n'
            '• 📅 Menu harian sehat untuk keluarga\n'
            '• 🌱 Tips berkebun dan pertanian\n'
            '• 💚 Info nutrisi dan manfaat sayuran\n\n'
            'Mau tanya apa hari ini?',
        timestamp: DateTime.now(),
        category: 'general',
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add(
        AiMessage(
          role: 'user',
          content: trimmed,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final result = await _service.sendMessage(
        userMessage: trimmed,
        history: _history,
      );

      // Simpan ke history untuk multi-turn
      _history.add({'role': 'user', 'content': trimmed});
      _history.add({'role': 'assistant', 'content': result.content});

      // Batasi history
      if (_history.length > 24) {
        _history = _history.sublist(_history.length - 24);
      }

      if (mounted) {
        setState(() {
          _messages.add(result);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            AiMessage(
              role: 'assistant',
              content:
                  'Maaf, terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}',
              timestamp: DateTime.now(),
              category: 'general',
            ),
          );
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _history.clear();
      _addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsBar(),
          Expanded(child: _buildMessageList()),
          if (_isLoading) _buildTypingIndicator(),
          _buildQuickPrompts(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D9E75), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D9E75).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gira AI',
                style: TextStyle(
                  fontSize: 15,
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
                    'Powered by Gemini AI',
                    style: TextStyle(
                      fontSize: 10,
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
        IconButton(
          onPressed: _clearChat,
          icon: const Icon(
            Icons.refresh_rounded,
            color: Color(0xFF7C7C7C),
            size: 20,
          ),
          tooltip: 'Reset chat',
        ),
      ],
    );
  }

  // ── Stats Bar ───────────────────────────────────────────────────────────────

  Widget _buildStatsBar() {
    final total = _stats['totalProducts'] ?? 0;
    final sellers = _stats['totalSellers'] ?? 0;
    final rating = _stats['avgRating'] ?? 0.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          _StatChip(icon: '🛍️', label: '$total Produk'),
          const SizedBox(width: 8),
          _StatChip(icon: '🏪', label: '$sellers Penjual'),
          const SizedBox(width: 8),
          _StatChip(icon: '⭐', label: '$rating Rating'),
        ],
      ),
    );
  }

  // ── Message List ────────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        if (msg.role == 'user') {
          return _UserBubble(message: msg);
        }
        return _AssistantBubble(message: msg);
      },
    );
  }

  // ── Typing Indicator ────────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D9E75), Color(0xFF2E7D32)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                ),
              ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  // ── Quick Prompts ───────────────────────────────────────────────────────────

  Widget _buildQuickPrompts() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _quickPrompts.map((p) {
            return GestureDetector(
              onTap: () => _sendMessage(p.text),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FBF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1D9E75).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      p.text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Input Bar ───────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tanya Gira apa saja...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontFamily: 'Montserrat',
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  onSubmitted: (v) {
                    _sendMessage(v);
                    _focusNode.requestFocus();
                  },
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _sendMessage(_textController.text);
                _focusNode.requestFocus();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF1D9E75), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: _isLoading ? Colors.grey[300] : null,
                  shape: BoxShape.circle,
                  boxShadow: _isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF1D9E75).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBDFCC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── User chat bubble ──────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final AiMessage message;

  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D9E75), Color(0xFF2E7D32)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D9E75).withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
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

// ── Assistant chat bubble ─────────────────────────────────────────────────────

class _AssistantBubble extends StatelessWidget {
  final AiMessage message;

  const _AssistantBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(message.category);
    final categoryIcon = _getCategoryIcon(message.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Gira
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D9E75), Color(0xFF2E7D32)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D9E75).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                if (message.category != null && message.category != 'general')
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoryIcon,
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCategoryLabel(message.category),
                          style: TextStyle(
                            fontSize: 10,
                            color: categoryColor,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main message bubble
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text (parse **bold**)
                      _RichText(text: message.content),

                      // Product recommendations
                      if (message.products.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const _SectionDivider(label: '🛍️ Produk Tersedia'),
                        const SizedBox(height: 8),
                        ...message.products.map(
                          (p) => _ProductCard(product: p),
                        ),
                      ],

                      // Recipe suggestions
                      if (message.recipes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const _SectionDivider(label: '👨‍🍳 Resep'),
                        const SizedBox(height: 8),
                        ...message.recipes.map(
                          (r) => _RecipeCard(recipe: r),
                        ),
                      ],

                      // Tip
                      if (message.tip != null && message.tip!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FBF5),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFF1D9E75),
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            message.tip!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1B5E20),
                              fontFamily: 'Montserrat',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? cat) {
    switch (cat) {
      case 'recipe':
        return Colors.orange;
      case 'farming':
        return Colors.green;
      case 'nutrition':
        return Colors.blue;
      case 'menu':
        return Colors.purple;
      case 'product':
        return const Color(0xFF1D9E75);
      default:
        return Colors.grey;
    }
  }

  String _getCategoryIcon(String? cat) {
    switch (cat) {
      case 'recipe':
        return '🍳';
      case 'farming':
        return '🌱';
      case 'nutrition':
        return '💚';
      case 'menu':
        return '📅';
      case 'product':
        return '🛒';
      default:
        return '💬';
    }
  }

  String _getCategoryLabel(String? cat) {
    switch (cat) {
      case 'recipe':
        return 'Resep';
      case 'farming':
        return 'Pertanian';
      case 'nutrition':
        return 'Nutrisi';
      case 'menu':
        return 'Menu';
      case 'product':
        return 'Rekomendasi Produk';
      default:
        return 'Umum';
    }
  }
}

// ── Section divider ────────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  final String label;

  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 1, color: const Color(0xFFE9E9E9)),
        ),
      ],
    );
  }
}

// ── Product card ───────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductSuggestion product;

  const _ProductCard({required this.product});

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                if (product.badge != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _badgeColor(product.badge!).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.badge!,
                      style: TextStyle(
                        fontSize: 10,
                        color: _badgeColor(product.badge!),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1B1B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 11,
                      color: Color(0xFF7C7C7C),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        product.sellerName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7C7C7C),
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatPrice(product.price)}/${product.unit}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1D9E75),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 11,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7C7C7C),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Reason
                if (product.reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '💡 ${product.reason}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF5A8A5A),
                      fontFamily: 'Montserrat',
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(String badge) {
    if (badge.contains('Termurah')) return Colors.blue;
    if (badge.contains('Terlaris')) return Colors.orange;
    if (badge.contains('Rating')) return const Color(0xFFFF9800);
    return const Color(0xFF1D9E75);
  }
}

// ── Recipe card ────────────────────────────────────────────────────────────────

class _RecipeCard extends StatefulWidget {
  final RecipeSuggestion recipe;

  const _RecipeCard({required this.recipe});

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE0A0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('🍳', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipe.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            _RecipeBadge(
                              icon: '⏱️',
                              text: widget.recipe.cookingTime,
                            ),
                            const SizedBox(width: 6),
                            _RecipeBadge(
                              icon: '📊',
                              text: widget.recipe.difficulty,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.orange,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFFFE0A0)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C7C7C),
                      fontFamily: 'Montserrat',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '🥬 Bahan-bahan:',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...widget.recipe.ingredients.map(
                    (ing) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(color: Colors.orange),
                          ),
                          Expanded(
                            child: Text(
                              ing,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                                color: Color(0xFF1B1B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '👨‍🍳 Cara Masak:',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...widget.recipe.steps.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8, top: 1),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                                color: Color(0xFF1B1B1B),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeBadge extends StatelessWidget {
  final String icon;
  final String text;

  const _RecipeBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$icon $text',
        style: const TextStyle(
          fontSize: 10,
          fontFamily: 'Montserrat',
          color: Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Rich text (parse **bold**) ─────────────────────────────────────────────────

class _RichText extends StatelessWidget {
  final String text;

  const _RichText({required this.text});

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

// ── Typing animation ───────────────────────────────────────────────────────────

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
                  color: Colors.grey[400],
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

// ── Quick prompt model ─────────────────────────────────────────────────────────

class _QuickPrompt {
  final String icon;
  final String text;
  final String category;

  const _QuickPrompt({
    required this.icon,
    required this.text,
    required this.category,
  });
}