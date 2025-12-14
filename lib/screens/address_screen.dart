import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/region_provider.dart';
import '../providers/auth_provider.dart';

class AddressScreen extends StatefulWidget {
  static String routeName = "/address";
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _addressDetail;
  String? _selectedDistrictId; // String based on your Laravel fix
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegionProvider>(context, listen: false).fetchDistricts();

      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        setState(() {
          _addressDetail = user.address;
          _selectedDistrictId = user.districtId;
        });
      }
    });
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSubmitting = true);

      try {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).updateAddress(_selectedDistrictId!, _addressDetail!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Alamat berhasil disimpan!"),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception:', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Alamat Pengiriman",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE0CC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFFF7643)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Pastikan alamat Anda benar agar kurir kami dapat mengantar kebab dengan cepat!",
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 1. Kota (Read Only)
                _buildLabel("Kota / Kabupaten"),
                TextFormField(
                  initialValue: "Makassar",
                  readOnly: true,
                  decoration: _inputDecoration(
                    hint: "Kota",
                    icon: Icons.location_city,
                    isLocked: true, // Custom visual for locked field
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Kecamatan (Dropdown)
                _buildLabel("Kecamatan"),
                Consumer<RegionProvider>(
                  builder: (context, region, child) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedDistrictId,
                      icon: region.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_drop_down),
                      items: region.districts.map((district) {
                        return DropdownMenuItem(
                          value: district.id,
                          child: Text(
                            district.name,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedDistrictId = value),
                      validator: (value) =>
                          value == null ? "Silahkan pilih kecamatan" : null,
                      decoration: _inputDecoration(
                        hint: "Pilih Kecamatan",
                        icon: Icons.map,
                      ),
                      isExpanded: true,
                      dropdownColor: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 3. Detail Alamat
                _buildLabel("Detail Alamat"),
                TextFormField(
                  initialValue: _addressDetail,
                  maxLines: 4,
                  onSaved: (value) => _addressDetail = value,
                  validator: (value) => (value == null || value.length < 10)
                      ? "Alamat terlalu pendek, mohon lengkapi"
                      : null,
                  decoration: _inputDecoration(
                    hint:
                        "Contoh: Jl. Perintis Kemerdekaan KM 10, Lorong 3, Rumah Pagar Hitam No. 5...",
                    icon: Icons.home,
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      elevation: 5,
                      shadowColor: const Color(
                        0xFFFF7643,
                      ).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SIMPAN ALAMAT",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool isLocked = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: isLocked ? Colors.grey : const Color(0xFFFF7643),
      ),
      filled: true,
      fillColor: isLocked ? Colors.grey.shade100 : const Color(0xFFF9F9F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF7643)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    );
  }
}
