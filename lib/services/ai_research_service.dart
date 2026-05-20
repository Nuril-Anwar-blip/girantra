import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model untuk pesan chat
// ─────────────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;
  final List<SellerRecommendation>? recommendations;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.recommendations,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Model untuk rekomendasi penjual
// ─────────────────────────────────────────────────────────────────────────────

class SellerRecommendation {
  final String sellerName;
  final String productName;
  final double price;
  final String unit;
  final double rating;
  final int score; // 0-100, dihitung oleh AI
  final String location;
  final int stock;
  final String imageUrl;
  final String label; // contoh: "Harga terbaik", "Rating tertinggi"
  final String labelType; // 'green' | 'amber' | 'blue'

  const SellerRecommendation({
    required this.sellerName,
    required this.productName,
    required this.price,
    required this.unit,
    required this.rating,
    required this.score,
    required this.location,
    required this.stock,
    required this.imageUrl,
    required this.label,
    required this.labelType,
  });

  factory SellerRecommendation.fromJson(Map<String, dynamic> json) {
    return SellerRecommendation(
      sellerName: json['seller_name'] ?? '',
      productName: json['product_name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? 'Kg',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      location: json['location'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] ?? '',
      label: json['label'] ?? '',
      labelType: json['label_type'] ?? 'green',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model ringkasan statistik marketplace
// ─────────────────────────────────────────────────────────────────────────────

class MarketStats {
  final int totalSellers;
  final int totalProducts;
  final double avgRating;

  const MarketStats({
    required this.totalSellers,
    required this.totalProducts,
    required this.avgRating,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Service utama
// ─────────────────────────────────────────────────────────────────────────────

class AiResearchService {
  final _supabase = Supabase.instance.client;

  // Ambil API key dari .env
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // ── 1. Ambil statistik marketplace ───────────────────────────────────────

  Future<MarketStats> fetchMarketStats() async {
    try {
      // Hitung jumlah penjual unik
      final sellersRes = await _supabase
          .from('users')
          .select('user_id')
          .eq('role', 'seller')
          .eq('account_status', 'active');

      // Hitung jumlah produk aktif
      final productsRes = await _supabase
          .from('products')
          .select('product_id')
          .eq('status_product', 'available');

      // Hitung rata-rata rating
      final ratingRes = await _supabase
          .from('products')
          .select('rating')
          .eq('status_product', 'available')
          .gt('rating', 0);

      double avgRating = 0.0;
      if (ratingRes.isNotEmpty) {
        final total = ratingRes.fold<double>(
          0,
          (sum, row) => sum + ((row['rating'] as num?)?.toDouble() ?? 0),
        );
        avgRating = total / ratingRes.length;
      }

      return MarketStats(
        totalSellers: sellersRes.length,
        totalProducts: productsRes.length,
        avgRating: double.parse(avgRating.toStringAsFixed(1)),
      );
    } catch (e) {
      // Fallback jika query gagal
      return const MarketStats(totalSellers: 0, totalProducts: 0, avgRating: 0);
    }
  }

  // ── 2. Ambil data produk + penjual dari Supabase ──────────────────────────

  Future<List<Map<String, dynamic>>> _fetchProductsContext(String query) async {
    try {
      // Ambil 30 produk terbaru yang available, join ke users & categories
      final response = await _supabase
          .from('products')
          .select('''
            product_id,
            product_name,
            description,
            selling_price,
            unit,
            stock,
            rating,
            image_url,
            harvest_date,
            status_product,
            seller_id,
            categories ( category_name ),
            users ( full_name, address )
          ''')
          .eq('status_product', 'available')
          .gt('stock', 0)
          .order('rating', ascending: false)
          .limit(30);

      // Hitung sold_count per produk dari transaksi yang sudah paid
      final txRes = await _supabase
          .from('transactions')
          .select('product_id, quantity, payment_status')
          .eq('payment_status', 'paid');

      // Buat map: product_id → total sold
      final soldMap = <String, int>{};
      for (final tx in txRes) {
        final pid = tx['product_id']?.toString() ?? '';
        final qty = (tx['quantity'] as num?)?.toInt() ?? 0;
        soldMap[pid] = (soldMap[pid] ?? 0) + qty;
      }

      // Gabungkan sold_count ke setiap produk
      return response.map<Map<String, dynamic>>((p) {
        return {
          'product_name': p['product_name'],
          'category': p['categories']?['category_name'] ?? 'Lainnya',
          'price': p['selling_price'],
          'unit': p['unit'],
          'stock': p['stock'],
          'rating': p['rating'],
          'sold_count': soldMap[p['product_id']?.toString() ?? ''] ?? 0,
          'seller_name': p['users']?['full_name'] ?? 'Penjual',
          'seller_address': p['users']?['address'] ?? '-',
          'image_url': p['image_url'] ?? '',
          'harvest_date': p['harvest_date'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ── 3. Bangun system prompt untuk Claude ─────────────────────────────────

  String _buildSystemPrompt(List<Map<String, dynamic>> products) {
    final productJson = jsonEncode(products);
    return '''
Kamu adalah Asisten Riset Penjual untuk aplikasi marketplace pertanian Girantra.
Tugasmu membantu pembeli menemukan penjual terbaik dan produk termurah.

DATA PRODUK AKTIF DI PLATFORM (real-time dari database):
$productJson

CARA MENJAWAB:
1. Analisis pertanyaan pengguna dan cocokkan dengan data di atas.
2. Rekomendasikan maksimal 3 produk/penjual terbaik.
3. Hitung "skor rekomendasi" (0–100) untuk setiap penjual berdasarkan:
   - Harga terjangkau (bobot 40%): bandingkan dengan rata-rata harga produk sejenis
   - Rating pembeli (bobot 35%): nilai 0–5 dikonversi ke 0–100
   - Stok tersedia (bobot 15%): lebih banyak = lebih aman
   - Volume penjualan (bobot 10%): produk populer = terpercaya
4. Berikan 1 insight/tip belanja yang actionable.

FORMAT RESPONS (WAJIB JSON VALID, tanpa markdown backtick):
{
  "message": "Pesan singkat dalam Bahasa Indonesia (1-2 kalimat pengantar)",
  "recommendations": [
    {
      "seller_name": "...",
      "product_name": "...",
      "price": 45000,
      "unit": "Kg",
      "rating": 4.5,
      "score": 92,
      "location": "Kota",
      "stock": 150,
      "image_url": "...",
      "label": "Harga terbaik",
      "label_type": "green"
    }
  ],
  "tip": "💡 Tip insight singkat dan actionable"
}

label_type harus salah satu dari: "green" (harga terbaik/murah), "blue" (rating tinggi/populer), "amber" (stok besar/cepat kirim).

Jika pertanyaan tidak berkaitan dengan produk/penjual, jawab dengan format:
{"message": "Pesan dalam Bahasa Indonesia", "recommendations": [], "tip": ""}

PENTING: Jawab HANYA dengan JSON valid. Tidak ada teks di luar JSON.
''';
  }

  // ── 4. Panggil OpenAI API ─────────────────────────────────────────────────

  Future<
    ({String message, List<SellerRecommendation> recommendations, String tip})
  >
  sendMessage({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY tidak ditemukan di file .env');
    }

    // Ambil konteks produk dari Supabase
    final products = await _fetchProductsContext(userMessage);

    // Susun history percakapan untuk multi-turn
    final messages = <Map<String, dynamic>>[];
    
    // Tambahkan system prompt sebagai instruksi utama
    messages.add({
      'role': 'system',
      'content': _buildSystemPrompt(products),
    });

    for (final hist in conversationHistory) {
      messages.add({'role': hist['role'], 'content': hist['content']});
    }
    messages.add({'role': 'user', 'content': userMessage});

    // Panggil OpenAI API
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'max_tokens': 1500,
        'response_format': {'type': 'json_object'},
        'messages': messages,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final rawText = data['choices'][0]['message']['content'] as String;

    // Parse JSON dari respons Claude
    try {
      final parsed = jsonDecode(rawText.trim()) as Map<String, dynamic>;
      final recs = (parsed['recommendations'] as List? ?? [])
          .map((r) => SellerRecommendation.fromJson(r as Map<String, dynamic>))
          .toList();

      return (
        message: parsed['message'] as String? ?? '',
        recommendations: recs,
        tip: parsed['tip'] as String? ?? '',
      );
    } catch (_) {
      // Fallback jika JSON tidak valid
      return (
        message: rawText,
        recommendations: <SellerRecommendation>[],
        tip: '',
      );
    }
  }
}
