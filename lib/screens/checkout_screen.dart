import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../providers/order_provider.dart';
import 'main_nav_screen.dart';
import 'payment_upload_screen.dart';
import '../utils/currency_format.dart'; // ✅ Import currency helper

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

      if (selectedPayment == 'QRIS') {
        final newOrder = orderProv.activeOrders.first;
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
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
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
      backgroundColor: const Color(0xFFFAFAFA), // Clean background
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Delivery Address Section
                _sectionTitle("Alamat Pengiriman"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                          Icons.location_on_rounded,
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
                                fontSize: 15,
                                color: Colors.black87,
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
                            if (primaryAddress != null)
                              Text(
                                primaryAddress.phoneNumber,
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

                // 2. Order Summary
                _sectionTitle("Ringkasan Pesanan"),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      // List Items (Collapsed if too many)
                      ...cart.items
                          .take(3)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Text(
                                    "${item.quantity}x",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF7643),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.product.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    (item.product.price * item.quantity)
                                        .toIDR(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (cart.items.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "+ ${cart.items.length - 3} menu lainnya",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const Divider(height: 25, color: Color(0xFFEEEEEE)),

                      _summaryRow("Subtotal", cart.subTotal.toIDR()),
                      const SizedBox(height: 8),
                      _summaryRow(
                        "Ongkos Kirim",
                        shippingCost == 0 ? "Gratis" : shippingCost.toIDR(),
                        isSuccess: shippingCost == 0,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: Color(0xFFEEEEEE),
                        ), // Dashed line effect simulation
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
                            grandTotal.toIDR(),
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

                // 3. Payment Method
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
                      const Divider(height: 1, indent: 60),
                      _paymentOption(
                        "QRIS / Transfer",
                        "Scan QR dan upload bukti",
                        Icons.qr_code_scanner_rounded,
                        "QRIS",
                      ),
                    ],
                  ),
                ),

                // Add bottom padding to scroll above the fixed button
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),

      // ✅ IMPROVED BOTTOM BAR (Total + Button)
      bottomNavigationBar: Consumer2<CartProvider, AddressProvider>(
        builder: (context, cart, addressProv, _) {
          final grandTotal =
              cart.subTotal + (addressProv.primaryAddress?.shippingCost ?? 0.0);
          final orderProv = Provider.of<OrderProvider>(context);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          grandTotal.toIDR(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: orderProv.isLoading
                            ? null
                            : _processCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7643),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFFFF7643).withOpacity(0.4),
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
                                    ? "Bayar Sekarang"
                                    : "Pesan Sekarang",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w800, // Extra bold
          fontSize: 16,
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
          color: const Color(0xFF9098B1).withOpacity(0.08), // Soft shadow
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSuccess ? Colors.green : Colors.black87,
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF7643) : Colors.grey[400],
              size: 28,
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
                      fontSize: 15,
                      color: isSelected ? Colors.black87 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF7643)
                      : Colors.grey[300]!,
                  width: isSelected ? 6 : 2, // Radio button effect
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
