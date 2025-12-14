import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../models/address_model.dart';
import 'address/address_list_screen.dart';
import 'checkout_screen.dart';

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
    // Listen to both Cart (for items) and Address (for shipping cost)
    return Consumer2<CartProvider, AddressProvider>(
      builder: (context, cart, addressProv, _) {
        final primaryAddress = addressProv.primaryAddress;

        // Calculate costs dynamically based on the currently selected address
        final shippingCost = primaryAddress?.shippingCost ?? 0.0;
        final grandTotal = cart.subTotal + shippingCost;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F9),
          appBar: AppBar(
            title: Column(
              children: [
                const Text(
                  "Keranjang",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "${cart.itemCount} items",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
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
                          vertical: 20,
                        ),
                        itemCount: cart.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) =>
                            CartItemCard(item: cart.items[index]),
                      ),
              ),
            ],
          ),
          // 3. Bottom Payment Summary
          bottomNavigationBar: _buildBottomSummary(
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
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Dikirim ke:",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (primary != null)
                const Text(
                  "Ubah",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF7643),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF7643),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: primary == null
                      ? const Text(
                          "Pilih Alamat Pengiriman",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${primary.label} • ${primary.recipientName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              primary.fullAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                ),
                if (primary == null)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
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
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tertiary Info (Subtotal & Shipping)
            _summaryRow("Subtotal", cart.subTotal),
            const SizedBox(height: 8),
            _summaryRow("Ongkos Kirim", shippingCost, isShipping: true),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Rp${grandTotal.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF7643),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

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
                            const SnackBar(
                              content: Text("Mohon pilih alamat pengiriman"),
                              backgroundColor: Colors.red,
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
                  elevation: 5,
                  shadowColor: const Color(0xFFFF7643).withValues(alpha: 0.3),
                ),
                child: const Text(
                  "Pesan Sekarang",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        Text(
          value == 0 && isShipping ? "Gratis" : "Rp${value.toStringAsFixed(0)}",
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
            Icon(Icons.delete_outline, color: Colors.red),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(product.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 15),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Rp${product.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Color(0xFFFF7643),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Quantity Control
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(
                    Icons.remove,
                    () => Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).decrementItem(product.id),
                  ),

                  SizedBox(
                    width: 30,
                    child: Center(
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  _iconBtn(
                    Icons.add,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Icon(icon, size: 16, color: Colors.black54),
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
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: Color(0xFFFF7643),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Keranjang Kosong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
