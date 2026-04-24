
class ProductModel{
  final int? product_id;        // int8
  final int category_id;        // int8
  final String product_name;    // varchar
  final String description;     // text
  final double cost_price;      // numeric
  final double selling_price;   // numeric
  final double ai_recommendation_price; // numeric
  final int stock;              // int8
  final String unit;            // varchar
  final String image_url;       // varchar
  final DateTime harvest_date;  // date
  final String status_product;  // status (Enum)
  final String seller_id;       // uuid
  final DateTime? created_at;   // timestamptz 
  final double rating;          // numeric

  ProductModel({
    required this.product_id,
    required this.category_id,
    required this.product_name,
    required this.description,
    required this.cost_price,
    required this.selling_price,
    required this.ai_recommendation_price,
    required this.stock,
    required this.unit,
    required this.image_url,
    required this.harvest_date,
    required this.status_product,
    required this.seller_id,
    required this.created_at,
    this.rating = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Helper: safe parse double dari berbagai tipe (String, int, double, null)
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    // Helper: safe parse int dari berbagai tipe
    int safeInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return ProductModel(
      product_id: json['product_id'] != null ? safeInt(json['product_id']) : null,
      category_id: safeInt(json['category_id']),
      product_name: json['product_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cost_price: safeDouble(json['cost_price']),
      selling_price: safeDouble(json['selling_price']),
      ai_recommendation_price: safeDouble(json['ai_recommendation_price']),
      stock: safeInt(json['stock']),
      unit: json['unit']?.toString() ?? '',
      image_url: json['image_url']?.toString() ?? '',
      harvest_date: json['harvest_date'] != null
          ? DateTime.parse(json['harvest_date'].toString())
          : DateTime.now(),
      status_product: json['status_product']?.toString() ?? 'available',
      seller_id: json['seller_id']?.toString() ?? '',
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      rating: safeDouble(json['rating']),
    );
  }
}
