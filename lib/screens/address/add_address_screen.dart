import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/region_provider.dart';
import '../../models/address_model.dart';

class AddAddressScreen extends StatefulWidget {
  static String routeName = "/add_address";

  final AddressModel? addressToEdit;

  const AddAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  String label = "Rumah";
  String? recipientName;
  String? phoneNumber;
  String? districtId;
  String? fullAddress;
  bool isLoading = false;

  final List<Map<String, dynamic>> _labelOptions = [
    {"label": "Rumah", "icon": Icons.home_rounded},
    {"label": "Kantor", "icon": Icons.work_rounded},
    {"label": "Apartemen", "icon": Icons.apartment_rounded},
    {"label": "Lainnya", "icon": Icons.location_on_rounded},
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegionProvider>(context, listen: false).fetchDistricts();
    });
    if (widget.addressToEdit != null) {
      final addr = widget.addressToEdit!;
      label = addr.label;
      recipientName = addr.recipientName;
      phoneNumber = addr.phoneNumber;
      districtId = addr.districtId;
      fullAddress = addr.fullAddress;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      try {
        final provider = Provider.of<AddressProvider>(context, listen: false);
        final data = {
          'label': label,
          'recipient_name': recipientName,
          'phone_number': phoneNumber,
          'district_id': districtId,
          'full_address': fullAddress,
        };

        if (widget.addressToEdit != null) {
          await provider.updateAddress(widget.addressToEdit!.id, data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Alamat berhasil diperbarui"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          await provider.addAddress(data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Alamat berhasil disimpan"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: $e"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.addressToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Alamat" : "Tambah Alamat",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Label Alamat",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 45,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _labelOptions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final option = _labelOptions[index];
                      final isSelected = label == option['label'];
                      return InkWell(
                        onTap: () => setState(() => label = option['label']),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF7643)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF7643)
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF7643,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                option['icon'],
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                option['label'],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  "Detail Penerima",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInput(
                  "Nama Penerima",
                  Icons.person_outline_rounded,
                  (v) => recipientName = v,
                  initialValue: recipientName,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  "Nomor HP",
                  Icons.phone_android_rounded,
                  (v) => phoneNumber = v,
                  type: TextInputType.phone,
                  initialValue: phoneNumber,
                ),
                const SizedBox(height: 30),

                const Text(
                  "Detail Lokasi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<RegionProvider>(
                  builder: (context, region, _) => DropdownButtonFormField<String>(
                    value:
                        districtId, // Use value instead of initialValue for dynamic updates
                    decoration: _inputDecoration(
                      "Kecamatan",
                      Icons.map_outlined,
                    ),
                    icon: region.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF7643),
                            ),
                          )
                        : const Icon(Icons.keyboard_arrow_down_rounded),
                    items: region.districts.map((d) {
                      return DropdownMenuItem(
                        value: d.id
                            .toString(), // Ensure IDs match type (String vs Int)
                        child: Text(
                          d.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => districtId = val),
                    validator: (v) =>
                        v == null ? "Silahkan pilih kecamatan" : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInput(
                  "Alamat Lengkap (Jalan, No. Rumah, RT/RW)",
                  Icons.location_on_outlined,
                  (v) => fullAddress = v,
                  maxLines: 3,
                  initialValue: fullAddress,
                  alignLabelWithHint: true,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: const Color(0xFFFF7643).withOpacity(0.4),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isEdit ? "SIMPAN PERUBAHAN" : "SIMPAN ALAMAT",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    IconData icon,
    Function(String?) onSaved, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? initialValue,
    bool alignLabelWithHint = false,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: _inputDecoration(
        label,
        icon,
        alignLabelWithHint: alignLabelWithHint,
      ),
      keyboardType: type,
      maxLines: maxLines,
      onSaved: onSaved,
      style: const TextStyle(fontSize: 14),
      validator: (v) => (v == null || v.length < 3) ? "Data tidak valid" : null,
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 8,
          bottom: alignLabelWithHint ? 48 : 0, // Align icon to top for textarea
        ),
        child: Icon(icon, color: const Color(0xFFFF7643), size: 22),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 40),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF7643), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
