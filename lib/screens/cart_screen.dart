import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // ✅ Required for currency formatting

// Providers
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';

// Models
import '../models/address_model.dart';

// Screens
import 'address/address_list_screen.dart';
import 'checkout_screen.dart';

// ✅ Local Helper Function (Fixes the "double has no instance method" error)
String formatRupiah(double price) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(price);
}

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch addresses fresh when entering cart to ensure shipping logic is correct
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, AddressProvider>(
      builder: (context, cart, addressProv, _) {
        final primaryAddress = addressProv.primaryAddress;

        // Calculate costs dynamically based on the currently selected address
        final shippingCost = primaryAddress?.shippingCost ?? 0.0;
        final grandTotal = cart.subTotal + shippingCost;

        return Scaffold(
          backgroundColor: const Color(
            0xFFFAFAFA,
          ), // Clean off-white background
          appBar: AppBar(
            title: Column(
              children: [
                const Text(
                  "Keranjang",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (cart.itemCount > 0)
                  Text(
                    "${cart.itemCount} item",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
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
          body: Column(
            children: [
              // 1. Address Header Section
              _buildAddressHeader(context, primaryAddress),

              // 2. Cart Items List
              Expanded(
                child: cart.items.isEmpty
                    ? const _EmptyCartState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: cart.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            CartItemCard(item: cart.items[index]),
                      ),
              ),
            ],
          ),
          // 3. Bottom Payment Summary (Hidden if empty)
          bottomNavigationBar: cart.items.isEmpty
              ? null
              : _buildBottomSummary(
                  context,
                  cart,
                  shippingCost,
                  grandTotal,
                  primaryAddress,
                ),
        );
      },
    );
  }

  Widget _buildAddressHeader(BuildContext context, AddressModel? primary) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          // Go to Address List to select/add address
          await Navigator.pushNamed(context, AddressListScreen.routeName);
          // Refresh data when returning
          if (context.mounted) {
            Provider.of<AddressProvider>(
              context,
              listen: false,
            ).fetchAddresses();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Dikirim ke:",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  primary != null ? "Ubah" : "Pilih",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFF7643),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: primary == null
                      ? const Text(
                          "Belum ada alamat terpilih",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${primary.label} • ${primary.recipientName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              primary.fullAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(
    BuildContext context,
    CartProvider cart,
    double shippingCost,
    double grandTotal,
    AddressModel? address,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -5),
            blurRadius: 20,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tertiary Info (Subtotal & Shipping)
            _summaryRow("Subtotal", cart.subTotal),
            const SizedBox(height: 10),
            _summaryRow("Ongkos Kirim", shippingCost, isShipping: true),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),

            // Primary Info (Grand Total)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                // ✅ Fixed: Using formatRupiah helper
                Text(
                  formatRupiah(grandTotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF7643),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: cart.items.isEmpty
                    ? null
                    : () {
                        if (address == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text("Mohon pilih alamat pengiriman"),
                                ],
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(20),
                            ),
                          );
                          return;
                        }

                        // Navigate to Checkout Page
                        Navigator.pushNamed(context, CheckoutScreen.routeName);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7643),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFFFF7643).withOpacity(0.4),
                ),
                child: const Text(
                  "Pesan Sekarang",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isShipping = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        // ✅ Fixed: Using formatRupiah helper
        Text(
          value == 0 && isShipping ? "Gratis" : formatRupiah(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isShipping && value == 0
                ? Colors.green
                : const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

class CartItemCard extends StatelessWidget {
  final dynamic item;
  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Dismissible(
      key: Key(product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE6E6),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Spacer(),
            Icon(Icons.delete_outline_rounded, color: Colors.red),
          ],
        ),
      ),
      onDismissed: (_) {
        Provider.of<CartProvider>(
          context,
          listen: false,
        ).removeItem(product.id);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ✅ Fixed: Using formatRupiah helper
                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(
                      color: Color(0xFFFF7643),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Quantity Control
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(
                    Icons.remove_rounded,
                    () => Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).decrementItem(product.id),
                  ),
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  _iconBtn(
                    Icons.add_rounded,
                    () => Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).addToCart(product),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 36,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: Colors.black54),
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Color(0xFFFF7643),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Keranjang Kosong",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Yuk, mulai pesan makanan favoritmu!",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
