import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/region_provider.dart';

class AddAddressScreen extends StatefulWidget {
  static String routeName = "/add_address";
  const AddAddressScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<RegionProvider>(context, listen: false).fetchDistricts();
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      try {
        await Provider.of<AddressProvider>(context, listen: false).addAddress({
          'label': label,
          'recipient_name': recipientName,
          'phone_number': phoneNumber,
          'district_id': districtId,
          'full_address': fullAddress,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Alamat berhasil disimpan"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan: $e"),
              backgroundColor: Colors.red,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tambah Alamat",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Label Alamat",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ["Rumah", "Kantor", "Apartemen"]
                      .map(
                        (l) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(l),
                            selected: label == l,
                            selectedColor: const Color(0xFFFF7643),
                            backgroundColor: const Color(0xFFF5F6F9),
                            labelStyle: TextStyle(
                              color: label == l ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) => setState(() => label = l),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: label == l
                                    ? const Color(0xFFFF7643)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 25),

                _buildInput(
                  "Nama Penerima",
                  Icons.person_outline,
                  (v) => recipientName = v,
                ),
                const SizedBox(height: 20),
                _buildInput(
                  "Nomor HP",
                  Icons.phone_android_outlined,
                  (v) => phoneNumber = v,
                  type: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                // Dropdown for District
                Consumer<RegionProvider>(
                  builder: (context, region, _) =>
                      DropdownButtonFormField<String>(
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
                                ),
                              )
                            : const Icon(Icons.arrow_drop_down),
                        items: region.districts
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => districtId = val,
                        validator: (v) =>
                            v == null ? "Silahkan pilih kecamatan" : null,
                      ),
                ),
                const SizedBox(height: 20),

                _buildInput(
                  "Alamat Lengkap",
                  Icons.location_on_outlined,
                  (v) => fullAddress = v,
                  maxLines: 3,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: const Color(
                        0xFFFF7643,
                      ).withValues(alpha: 0.4),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SIMPAN ALAMAT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

  Widget _buildInput(
    String label,
    IconData icon,
    Function(String?) onSaved, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: _inputDecoration(label, icon),
      keyboardType: type,
      maxLines: maxLines,
      onSaved: onSaved,
      validator: (v) =>
          (v == null || v.length < 3) ? "$label tidak valid" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon, color: const Color(0xFFFF7643)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFF7643), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
    );
  }
}
