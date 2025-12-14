class AddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String districtId;
  final String fullAddress;
  final bool isPrimary;
  final double shippingCost; // ✅ Field to hold the price

  AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.districtId,
    required this.fullAddress,
    required this.isPrimary,
    required this.shippingCost,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      label: json['label'],
      recipientName: json['recipient_name'],
      phoneNumber: json['phone_number'],
      districtId: json['district_id'],
      fullAddress: json['full_address'],
      isPrimary: json['is_primary'] == 1 || json['is_primary'] == true,

      // ✅ Parse the price we sent from Laravel
      // We use tryParse to be safe against nulls or string/number formats
      shippingCost:
          double.tryParse(json['shipping_cost'].toString()) ?? 15000.0,
    );
  }
}
