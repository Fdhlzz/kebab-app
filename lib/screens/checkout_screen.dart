import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../providers/order_provider.dart';
import 'main_nav_screen.dart';

class CheckoutScreen extends StatefulWidget {
  static String routeName = "/checkout";
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPayment = "COD";

  void _processCheckout() async {
    final cartProv = Provider.of<CartProvider>(context, listen: false);
    final addressProv = Provider.of<AddressProvider>(context, listen: false);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);

    if (addressProv.primaryAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Alamat tidak ditemukan"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool success = await orderProv.createOrder(
      addressId: addressProv.primaryAddress!.id,
      items: cartProv.items,
      subtotal: cartProv.subTotal,
      shippingCost: cartProv.shippingCost,
    );

    if (success) {
      cartProv.clearCart();
      if (!mounted) return;
      _showSuccessDialog();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal membuat pesanan"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pesanan Berhasil!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              "Pesanan Anda sedang diproses.\nMohon tunggu kurir kami.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7643),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    ctx,
                    MainNavScreen.routeName,
                    (route) => false,
                  );
                },
                child: const Text(
                  "Kembali ke Beranda",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<CartProvider, AddressProvider>(
        builder: (context, cart, addressProv, _) {
          final primaryAddress = addressProv.primaryAddress;
          final shippingCost = primaryAddress?.shippingCost ?? 0.0;
          final grandTotal = cart.subTotal + shippingCost;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. DELIVERY ADDRESS CARD
                _sectionTitle("Alamat Pengiriman"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFFFF7643),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primaryAddress != null
                                  ? "${primaryAddress.label} • ${primaryAddress.recipientName}"
                                  : "Belum ada alamat",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              primaryAddress?.fullAddress ??
                                  "Silahkan pilih alamat di keranjang",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              primaryAddress?.phoneNumber ?? "-",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 2. ORDER SUMMARY CARD
                _sectionTitle("Ringkasan Pesanan"),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      ...cart.items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F6F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${item.quantity}x",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF7643),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      item.product.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Rp${(item.product.price * item.quantity).toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      const Divider(height: 30, color: Color(0xFFF0F0F0)),
                      _summaryRow(
                        "Subtotal Produk",
                        "Rp${cart.subTotal.toStringAsFixed(0)}",
                      ),
                      const SizedBox(height: 12),
                      _summaryRow(
                        "Ongkos Kirim",
                        "Rp${shippingCost.toStringAsFixed(0)}",
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Divider(color: Color(0xFFF0F0F0)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Tagihan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Rp${grandTotal.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Color(0xFFFF7643),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 3. PAYMENT METHOD CARD
                _sectionTitle("Metode Pembayaran"),
                Container(
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _paymentOption(
                        "COD (Bayar di Tempat)",
                        "Bayar tunai saat kurir tiba",
                        Icons.payments_outlined,
                        "COD",
                      ),
                      // Divider line between options if added later
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<OrderProvider>(
        builder: (context, orderProv, _) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: orderProv.isLoading ? null : _processCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7643),
                disabledBackgroundColor: const Color(
                  0xFFFF7643,
                ).withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 5,
                shadowColor: const Color(0xFFFF7643).withValues(alpha: 0.3),
              ),
              child: orderProv.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      "KONFIRMASI PESANAN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _paymentOption(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    final isSelected = selectedPayment == value;
    return InkWell(
      onTap: () => setState(() => selectedPayment = value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFFF7643) : Colors.grey,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFFFF7643)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFFFF7643) : Colors.grey[300],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
