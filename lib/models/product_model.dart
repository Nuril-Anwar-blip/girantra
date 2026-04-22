
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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      product_id: json['product_id'],
      category_id: json['category_id'],
      product_name: json['product_name'],
      description: json['description'],
      cost_price: json['cost_price'],
      selling_price: json['selling_price'] != null ? double.parse(json['selling_price'].toString()) : 0.0,
      ai_recommendation_price: json['ai_recommendation_price'] != null ? double.parse(json['ai_recommendation_price'].toString()) : 0.0,
      stock: json['stock'],
      unit: json['unit'],
      image_url: json['image_url'],
      harvest_date: json['harvest_date'] != null ? DateTime.parse(json['harvest_date'].toString()) : DateTime.now(),
      status_product: json['status_product'],
      seller_id: json['seller_id'],
      created_at: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}