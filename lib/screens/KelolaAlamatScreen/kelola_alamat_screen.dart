// lib/screens/KelolaAlamatScreen/kelola_alamat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';

class KelolaAlamatScreen extends StatefulWidget {
  final AddressModel? address;
  const KelolaAlamatScreen({super.key, this.address});

  @override
  State<KelolaAlamatScreen> createState() => _KelolaAlamatScreenState();
}

class _KelolaAlamatScreenState extends State<KelolaAlamatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int _selectedLabel = 0;
  bool _isPrimary = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _labelOptions = const [
    {'icon': Icons.home_rounded, 'label': 'Rumah'},
    {'icon': Icons.business_rounded, 'label': 'Kantor'},
    {'icon': Icons.location_on_rounded, 'label': 'Lainnya'},
  ];

  LatLng _selectedLatLng = const LatLng(-7.250445, 112.768845);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final a = widget.address!;
      _nameCtrl.text = a.recipientName;
      _phoneCtrl.text = a.phoneNumber;
      _streetCtrl.text = a.street;
      _villageCtrl.text = a.village;
      _districtCtrl.text = a.district;
      _cityCtrl.text = a.city;
      _provinceCtrl.text = a.province;
      _postalCtrl.text = a.postalCode;
      _isPrimary = a.isPrimary;
      _selectedLatLng = LatLng(a.latitude, a.longitude);
      final idx = _labelOptions.indexWhere((e) => e['label'] == a.label);
      _selectedLabel = idx >= 0 ? idx : 0;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _villageCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _provinceCtrl.dispose();
    _postalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newAddress = AddressModel(
      id: widget.address?.id ?? '',
      label: _labelOptions[_selectedLabel]['label'] as String,
      recipientName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      village: _villageCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      province: _provinceCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim(),
      latitude: _selectedLatLng.latitude,
      longitude: _selectedLatLng.longitude,
      isPrimary: _isPrimary,
    );

    final provider = context.read<AddressProvider>();
    final error = await provider.saveAddress(newAddress, isNew: widget.address == null);

    setState(() => _isLoading = false);

    if (error == null && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gagal menyimpan alamat'), backgroundColor: Colors.red));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: const Color(0xFF00682B).withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Color(0xFF00682B), size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Alamat Berhasil Disimpan', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1B))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 44,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Selesai', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F8),
        elevation: 0,
        title: Text(widget.address == null ? 'Tambah Alamat' : 'Edit Alamat', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B))),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMapSection(),
              const SizedBox(height: 16),
              _buildFormSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyBottomBar(),
    );
  }

  Widget _buildMapSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Titik Lokasi', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLatLng,
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) {
                    setState(() => _selectedLatLng = point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLatLng,
                        width: 40, height: 40,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Koordinat: ${_selectedLatLng.latitude.toStringAsFixed(6)}, ${_selectedLatLng.longitude.toStringAsFixed(6)}', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: Color(0xFF424656))),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Penerima', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B))),
          const SizedBox(height: 12),
          _buildTextField(label: 'Nama Penerima', controller: _nameCtrl, hint: 'Nama lengkap'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Nomor WhatsApp / Seluler', controller: _phoneCtrl, hint: '812-3456-7890', keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextField(label: 'Jalan & No. Rumah', controller: _streetCtrl, hint: 'Jl. Raya Darmo No. 25'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Desa/Kelurahan', controller: _villageCtrl, hint: 'Wonokromo')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: 'Kecamatan', controller: _districtCtrl, hint: 'Wonokromo')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Kota/Kabupaten', controller: _cityCtrl, hint: 'Surabaya')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: 'Provinsi', controller: _provinceCtrl, hint: 'Jawa Timur')),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Kode Pos', controller: _postalCtrl, hint: '60241', keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _buildTextField(label: 'Catatan Khusus Kurir Rantai Dingin', controller: _notesCtrl, hint: 'Pagar hitam nomor 25, letakkan paket di cooler box depan teras', maxLines: 3),
          const SizedBox(height: 16),
          const Text('Label Alamat', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B))),
          const SizedBox(height: 6),
          Row(
            children: List.generate(_labelOptions.length, (i) {
              final isActive = _selectedLabel == i;
              final item = _labelOptions[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == _labelOptions.length - 1 ? 0 : 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedLabel = i),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(color: isActive ? AppColors.primary : const Color(0xFFF6F3F2), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'] as IconData, size: 14, color: isActive ? Colors.white : const Color(0xFF424656)),
                          const SizedBox(width: 4),
                          Text(item['label'] as String, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : const Color(0xFF424656))),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Text('Jadikan sebagai Alamat Utama', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B)))),
              Switch(value: _isPrimary, activeColor: AppColors.primary, onChanged: (val) => setState(() => _isPrimary = val)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint, TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF6F3F2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))]),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Simpan Alamat', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}