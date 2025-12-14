import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/region_provider.dart';
import '../../models/address_model.dart'; // Import Model

class AddAddressScreen extends StatefulWidget {
  static String routeName = "/add_address";

  // ✅ Optional parameter: If passed, we are in EDIT mode
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
              ),
            );
          }
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Alamat" : "Tambah Alamat",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
                  initialValue: recipientName,
                ),
                const SizedBox(height: 20),
                _buildInput(
                  "Nomor HP",
                  Icons.phone_android_outlined,
                  (v) => phoneNumber = v,
                  type: TextInputType.phone,
                  initialValue: phoneNumber,
                ),
                const SizedBox(height: 20),

                Consumer<RegionProvider>(
                  builder: (context, region, _) =>
                      DropdownButtonFormField<String>(
                        initialValue: districtId,
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
                  initialValue: fullAddress,
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
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isEdit ? "UPDATE ALAMAT" : "SIMPAN ALAMAT",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
    String? initialValue,
  }) {
    return TextFormField(
      initialValue: initialValue,
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
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
    );
  }
}
