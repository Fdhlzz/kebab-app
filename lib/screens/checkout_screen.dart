import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../providers/order_provider.dart';
import 'main_nav_screen.dart';
import 'payment_upload_screen.dart'; // ✅ Create this file next

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
      paymentMethod: selectedPayment,
    );

    if (success) {
      cartProv.clearCart();
      if (!mounted) return;

      // ✅ LOGIC: Where to go?
      if (selectedPayment == 'QRIS') {
        // 1. Get the new order ID (Provider refreshed it, so it's the first one)
        final newOrder = orderProv.activeOrders.first;

        // 2. Go to Upload Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentUploadScreen(
              orderId: newOrder.id,
              total: newOrder.grandTotal,
            ),
          ),
        );
      } else {
        // 3. COD -> Show Success
        _showSuccessDialog();
      }
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
                _sectionTitle("Alamat Pengiriman"),
                // ... (Keep existing Address Card Code) ...
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

                // ... (Keep existing Summary Card Code) ...
                _sectionTitle("Ringkasan Pesanan"),
                Container(
                  // ... keep existing summary card content
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      ...cart.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              Text(
                                "${item.quantity}x ${item.product.title}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Rp${(item.product.price * item.quantity).toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 30),
                      _summaryRow(
                        "Subtotal",
                        "Rp${cart.subTotal.toStringAsFixed(0)}",
                      ),
                      const SizedBox(height: 10),
                      _summaryRow(
                        "Ongkos Kirim",
                        "Rp${shippingCost.toStringAsFixed(0)}",
                      ),
                      const Divider(height: 30),
                      _summaryRow(
                        "Total Tagihan",
                        "Rp${grandTotal.toStringAsFixed(0)}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ✅ UPDATED PAYMENT SECTION
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
                      const Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                      ), // Divider Line
                      _paymentOption(
                        "QRIS / Transfer Manual",
                        "Scan QR dan upload bukti",
                        Icons.qr_code_scanner,
                        "QRIS",
                      ),
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
                color: Colors.black.withOpacity(0.05),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 5,
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
                  : Text(
                      selectedPayment == 'QRIS'
                          ? "LANJUT PEMBAYARAN"
                          : "KONFIRMASI PESANAN",
                      style: const TextStyle(
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

  // ... (Keep your helpers: _sectionTitle, _cardDecoration, _summaryRow, _paymentOption) ...
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
          color: Colors.black.withOpacity(0.04),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF7643).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
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
            ),
          ],
        ),
      ),
    );
  }
}
