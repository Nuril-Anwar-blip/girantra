/// Konstanta global aplikasi Girantra.
/// Ubah nilai di sini untuk berlaku di seluruh aplikasi.
class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ── Biaya Transaksi ────────────────────────────────────────────────────────
  /// Biaya pengiriman tetap per transaksi (dalam Rupiah)
  static const double shippingFee = 5000;

  /// Biaya layanan platform per transaksi (dalam Rupiah)
  static const double serviceFee = 2500;

  /// Total biaya tambahan (shippingFee + serviceFee)
  static const double totalFee = shippingFee + serviceFee;
}
