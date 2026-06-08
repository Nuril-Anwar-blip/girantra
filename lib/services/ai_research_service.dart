import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model classes
// ─────────────────────────────────────────────────────────────────────────────

class AiMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;
  final List<ProductSuggestion> products;
  final List<RecipeSuggestion> recipes;
  final String? tip;
  final String? category; // 'product', 'recipe', 'general', 'farming', 'nutrition', 'menu'

  const AiMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.products = const [],
    this.recipes = const [],
    this.tip,
    this.category,
  });
}

class ProductSuggestion {
  final String productName;
  final String sellerName;
  final double price;
  final String unit;
  final double rating;
  final int stock;
  final String imageUrl;
  final String location;
  final String reason;
  final String? badge; // 'Terlaris' | 'Termurah' | 'Rating Terbaik' | 'Segar' | 'Stok Banyak'

  const ProductSuggestion({
    required this.productName,
    required this.sellerName,
    required this.price,
    required this.unit,
    required this.rating,
    required this.stock,
    required this.imageUrl,
    required this.location,
    required this.reason,
    this.badge,
  });

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    return ProductSuggestion(
      productName: json['product_name']?.toString() ?? '',
      sellerName:  json['seller_name']?.toString()  ?? '',
      price:    (json['price']  as num?)?.toDouble() ?? 0,
      unit:      json['unit']?.toString()            ?? '',
      rating:   (json['rating'] as num?)?.toDouble() ?? 0,
      stock:    (json['stock']  as num?)?.toInt()    ?? 0,
      imageUrl:  json['image_url']?.toString()       ?? '',
      location:  json['location']?.toString()        ?? '',
      reason:    json['reason']?.toString()          ?? '',
      badge:     json['badge']?.toString(),
    );
  }
}

class RecipeSuggestion {
  final String name;
  final String description;
  final List<String> ingredients;
  final String cookingTime;
  final String difficulty; // 'Mudah' | 'Sedang' | 'Sulit'
  final List<String> steps;

  const RecipeSuggestion({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.cookingTime,
    required this.difficulty,
    required this.steps,
  });

  factory RecipeSuggestion.fromJson(Map<String, dynamic> json) {
    return RecipeSuggestion(
      name:        json['name']?.toString()        ?? '',
      description: json['description']?.toString() ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      cookingTime: json['cooking_time']?.toString() ?? '',
      difficulty:  json['difficulty']?.toString()   ?? 'Sedang',
      steps:       List<String>.from(json['steps'] ?? []),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Service — menggunakan Google Gemini API
// ─────────────────────────────────────────────────────────────────────────────

class AiAssistantService {
  final _supabase = Supabase.instance.client;

  // Ambil API key dari .env  (key: GEMINI_API_KEY)
  String get _apiKey =>
      dotenv.env['GEMINI_API_KEY'] ??
      dotenv.env['GEMINI_API'] ??
      '';

  // Cache model agar tidak dibuat ulang setiap panggilan
  GenerativeModel? _cachedModel;
  String _cachedSystemPrompt = '';

  // ── Ambil data produk real-time dari Supabase ─────────────────────────────

  Future<List<Map<String, dynamic>>> _fetchAvailableProducts() async {
    try {
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
            categories ( category_name ),
            users      ( full_name, address )
          ''')
          .eq('status_product', 'available')
          .gt('stock', 0)
          .order('rating', ascending: false)
          .limit(40);

      // Hitung sold_count dari transaksi yang sudah paid
      final txRes = await _supabase
          .from('transactions')
          .select('product_id, quantity')
          .eq('payment_status', 'paid');

      final soldMap = <String, int>{};
      for (final tx in txRes) {
        final pid = tx['product_id']?.toString() ?? '';
        final qty = (tx['quantity'] as num?)?.toInt() ?? 0;
        soldMap[pid] = (soldMap[pid] ?? 0) + qty;
      }

      return response.map<Map<String, dynamic>>((p) => <String, dynamic>{
        'product_name':   p['product_name'],
        'category':       p['categories']?['category_name'] ?? 'Lainnya',
        'price':          p['selling_price'],
        'unit':           p['unit'],
        'stock':          p['stock'],
        'rating':         p['rating'],
        'sold_count':     soldMap[p['product_id']?.toString() ?? ''] ?? 0,
        'seller_name':    p['users']?['full_name'] ?? 'Penjual',
        'seller_address': p['users']?['address']   ?? '',
        'image_url':      p['image_url']            ?? '',
        'harvest_date':   p['harvest_date'],
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Bangun system prompt ──────────────────────────────────────────────────

  String _buildSystemPrompt(List<Map<String, dynamic>> products) {
    final productJson = jsonEncode(products);
    return '''
Kamu adalah Asisten Cerdas bernama "Gira" untuk aplikasi marketplace pertanian Girantra (Indonesia).
Kamu ramah, helpful, dan berbicara natural dalam Bahasa Indonesia.

KEMAMPUANMU (tidak terbatas hanya produk marketplace):
1. Rekomendasi produk terbaik dari marketplace berdasarkan kebutuhan
2. Resep masakan lengkap — BEBAS, tidak harus dari produk marketplace
3. Saran menu harian / mingguan yang sehat dan bergizi
4. Tips berkebun, menanam, memupuk, mengatasi hama
5. Informasi nutrisi dan manfaat sayuran / buah / rempah
6. Saran diet, pola makan sehat, dan gaya hidup
7. Pertanyaan umum seputar pertanian, pangan, dan masakan

DATA PRODUK AKTIF DI MARKETPLACE GIRANTRA (real-time):
$productJson

ATURAN PENTING:
- Jawab secara natural sebagai AI. Jika ditanya harga pasar umum (misal harga benih padi), sebutkan kisaran harga angkanya saja dalam `message`. JANGAN memaksakan untuk menampilkan produk dari marketplace kecuali user secara eksplisit mencari/membeli produk.
- Jika pertanyaan di luar konteks produk/resep (misalnya ngobrol santai atau tanya teori), jawab saja di `message` dan kosongkan array `products` dan `recipes` (yaitu: []).
- Jika merekomendasikan produk marketplace (KARENA user mencari barang), gunakan data produk di atas.
- Berikan respons yang detail, ramah, dan actionable.

FORMAT RESPONS — WAJIB JSON MURNI TANPA MARKDOWN (Tanpa awalan ```json):
{
  "message": "Pesan utama (boleh panjang, gunakan **teks** untuk bold)",
  "category": "product|recipe|farming|general|nutrition|menu",
  "products": [
    {
      "product_name": "...",
      "seller_name": "...",
      "price": 45000,
      "unit": "Kg",
      "rating": 4.5,
      "stock": 100,
      "image_url": "...",
      "location": "...",
      "reason": "Alasan singkat mengapa cocok",
      "badge": "Termurah|Terlaris|Rating Terbaik|Segar|Stok Banyak"
    }
  ],
  "recipes": [
    {
      "name": "Nama Masakan",
      "description": "Deskripsi singkat",
      "ingredients": ["200g bayam segar", "3 siung bawang putih", "..."],
      "cooking_time": "30 menit",
      "difficulty": "Mudah|Sedang|Sulit",
      "steps": ["Langkah 1...", "Langkah 2...", "..."]
    }
  ],
  "tip": "💡 Tip atau insight tambahan yang berguna (opsional, boleh kosong string)"
}

Jika tidak ada produk atau resep yang relevan, gunakan array kosong [].
PENTING: Hanya kembalikan JSON valid. Tidak ada teks apapun di luar JSON.
''';
  }

  // ── Daftar model fallback (dicoba berurutan) ────────────────────────────

  static const List<String> _modelNames = [
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.0-flash-lite',
  ];

  // ── Buat GenerativeModel ──────────────────────────────────────────────────

  GenerativeModel _buildModel(String modelName, String systemPrompt) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
      ),
    );
  }

  // ── Kirim pesan ke Gemini (dengan retry & fallback model) ─────────────────

  Future<AiMessage> sendMessage({
    required String userMessage,
    required List<Map<String, dynamic>> history,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY tidak ditemukan di file .env.\n'
        'Tambahkan: GEMINI_API_KEY=AIzaSy...',
      );
    }

    // Ambil produk terkini
    final products = await _fetchAvailableProducts();
    final systemPrompt = _buildSystemPrompt(products);

    // Susun history untuk Gemini SDK
    final geminiHistory = <Content>[];
    for (final h in history) {
      final role = h['role'] == 'assistant' ? 'model' : 'user';
      geminiHistory.add(Content(role, [TextPart(h['content'] as String)]));
    }

    // Coba setiap model secara berurutan
    String lastError = '';
    for (final modelName in _modelNames) {
      try {
        final model = _buildModel(modelName, systemPrompt);
        final chat = model.startChat(history: geminiHistory);

        // Retry hingga 2x jika error 503
        for (int attempt = 0; attempt < 2; attempt++) {
          try {
            final response = await chat.sendMessage(Content.text(userMessage));
            final rawText = response.text ?? '';
            // Berhasil — cache model ini untuk panggilan berikutnya
            return _parseResponse(rawText);
          } on GenerativeAIException catch (e) {
            if (e.message.contains('503') || e.message.contains('UNAVAILABLE')) {
              // Tunggu sebentar lalu retry
              await Future.delayed(const Duration(seconds: 2));
              continue;
            }
            rethrow;
          }
        }
      } on GenerativeAIException catch (e) {
        lastError = e.message;
        // Lanjut ke model berikutnya
        continue;
      } catch (e) {
        lastError = e.toString();
        continue;
      }
    }

    throw Exception('Semua model sedang sibuk. Coba lagi nanti.\n$lastError');
  }

  // ── Parse JSON dari Gemini ────────────────────────────────────────────────

  AiMessage _parseResponse(String rawText) {
    try {
      String clean = rawText.trim();
      // Bersihkan markdown code block dan ambil hanya bagian JSON
      final startIndex = clean.indexOf('{');
      final endIndex = clean.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        clean = clean.substring(startIndex, endIndex + 1);
      }

      final parsed = jsonDecode(clean) as Map<String, dynamic>;

      final products = (parsed['products'] as List? ?? [])
          .map((p) => ProductSuggestion.fromJson(p as Map<String, dynamic>))
          .toList();

      final recipes = (parsed['recipes'] as List? ?? [])
          .map((r) => RecipeSuggestion.fromJson(r as Map<String, dynamic>))
          .toList();

      return AiMessage(
        role:      'assistant',
        content:   parsed['message']  as String? ?? rawText,
        timestamp: DateTime.now(),
        products:  products,
        recipes:   recipes,
        tip:       parsed['tip']      as String?,
        category:  parsed['category'] as String?,
      );
    } catch (_) {
      // Fallback: tampilkan teks mentah jika JSON tidak valid
      return AiMessage(
        role:      'assistant',
        content:   rawText,
        timestamp: DateTime.now(),
        category:  'general',
      );
    }
  }

  // ── Statistik marketplace ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchMarketStats() async {
    try {
      final sellers = await _supabase
          .from('users')
          .select('user_id')
          .eq('role', 'seller')
          .eq('account_status', 'active');

      final products = await _supabase
          .from('products')
          .select('product_id')
          .eq('status_product', 'available');

      final ratings = await _supabase
          .from('products')
          .select('rating')
          .eq('status_product', 'available')
          .gt('rating', 0);

      double avgRating = 0;
      if (ratings.isNotEmpty) {
        final total = ratings.fold<double>(
          0,
          (sum, r) => sum + ((r['rating'] as num?)?.toDouble() ?? 0),
        );
        avgRating = total / ratings.length;
      }

      return {
        'totalSellers': sellers.length,
        'totalProducts': products.length,
        'avgRating': double.parse(avgRating.toStringAsFixed(1)),
      };
    } catch (_) {
      return {'totalSellers': 0, 'totalProducts': 0, 'avgRating': 0.0};
    }
  }
}