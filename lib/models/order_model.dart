import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final double totalPrice;
  final double shippingCost;
  final double grandTotal;
  final DateTime date;
  final String shippingAddress;
  final List<OrderItem> items;

  // ✅ NEW PAYMENT FIELDS
  final String paymentMethod; // 'COD' or 'QRIS'
  final String paymentStatus; // 'unpaid', 'paid'
  final String? paymentProof; // Full URL to image, or null

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalPrice,
    required this.shippingCost,
    required this.grandTotal,
    required this.date,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentProof,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    double parseDouble(dynamic val) => double.tryParse(val.toString()) ?? 0.0;

    // Timezone Logic (WITA)
    String rawDate = json['created_at'] ?? DateTime.now().toString();
    if (!rawDate.contains('+') && !rawDate.endsWith('Z')) {
      rawDate = "$rawDate+0800";
    }

    double subTotal = parseDouble(json['total_price']);
    double shipCost = parseDouble(json['shipping_cost']);

    // ✅ Payment Proof URL Logic
    String? proofUrl;
    if (json['payment_proof'] != null) {
      String rawPath = json['payment_proof'];
      if (rawPath.startsWith('http')) {
        proofUrl = rawPath;
      } else {
        proofUrl = '${AppConstants.storageUrl}/$rawPath';
      }
    }

    return Order(
      id: json['id'],
      orderNumber: "ORD-#${json['id']}",
      status: json['status'] ?? 'pending',
      totalPrice: subTotal,
      shippingCost: shipCost,
      // Use backend grand_total if available, else calculate
      grandTotal: json['grand_total'] != null
          ? parseDouble(json['grand_total'])
          : subTotal + shipCost,
      date: DateTime.parse(rawDate).toLocal(),
      shippingAddress: json['shipping_address'] ?? 'Alamat tidak tersedia',
      items: itemsList,

      // ✅ Map New Fields
      paymentMethod: json['payment_method'] ?? 'COD',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      paymentProof: proofUrl,
    );
  }

  // --- UI Helpers ---

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'on_delivery':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return "Menunggu Konfirmasi";
      case 'processing':
        return "Sedang Disiapkan";
      case 'on_delivery':
        return "Dalam Pengiriman";
      case 'completed':
        return "Selesai";
      case 'cancelled':
        return "Dibatalkan";
      default:
        return status;
    }
  }

  // ✅ New Helper for Payment Status Color
  Color get paymentStatusColor {
    if (paymentStatus == 'paid') return Colors.green;
    return Colors.redAccent;
  }
}

class OrderItem {
  final int id;
  final String productName;
  final int quantity;
  final double price;
  final String image;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    var productData = json['product'];
    String imageUrl = '';

    if (productData != null && productData['images'] != null) {
      var imagesList = productData['images'] as List;
      if (imagesList.isNotEmpty) {
        String rawPath = imagesList[0]['image_path'] ?? '';
        if (rawPath.isNotEmpty) {
          if (rawPath.startsWith('http')) {
            imageUrl = rawPath;
          } else {
            imageUrl = '${AppConstants.storageUrl}/$rawPath';
          }
        }
      }
    }

    return OrderItem(
      id: json['id'],
      productName: productData != null ? productData['name'] : 'Item Unknown',
      image: imageUrl,
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }
}
