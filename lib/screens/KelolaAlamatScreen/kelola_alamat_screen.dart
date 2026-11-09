// lib/screens/KelolaAlamatScreen/kelola_alamat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';

class KelolaAlamatScreen extends StatefulWidget {
  const KelolaAlamatScreen({super.key});

  @override
  State<KelolaAlamatScreen> createState() => _KelolaAlamatScreenState();
}

class _KelolaAlamatScreenState extends State<KelolaAlamatScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _notesCtrl;
  int _selectedLabel = 0;
  bool _isPrimary = true;
  bool _isLocating = false;

  final List<Map<String, dynamic>> _labelOptions = const [
    {'icon': Icons.home_rounded, 'label': 'Rumah'},
    {'icon': Icons.business_rounded, 'label': 'Kantor'},
    {'icon': Icons.location_on_rounded, 'label': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    final addr = context.read<AddressProvider>().currentAddress;
    _nameCtrl = TextEditingController(text: addr.recipientName);
    _phoneCtrl = TextEditingController(text: addr.phoneNumber);
    _addressCtrl = TextEditingController(text: addr.fullAddress);
    _notesCtrl = TextEditingController(text: addr.notes);
    _isPrimary = addr.isPrimary;
    final idx = _labelOptions.indexWhere((e) => e['label'] == addr.label);
    _selectedLabel = idx >= 0 ? idx : 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveAddress() {
    final newAddress = AddressModel(
      recipientName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      fullAddress: _addressCtrl.text.trim(),
      label: _labelOptions[_selectedLabel]['label'] as String,
      notes: _notesCtrl.text.trim(),
      isPrimary: _isPrimary,
    );

    context.read<AddressProvider>().updateAddress(newAddress);
    _showSuccessDialog();
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF00682B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF00682B), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Alamat Berhasil Diperbarui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1B1B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Alamat pengiriman kamu sudah tersimpan. Titik lokasi akan digunakan untuk rute kurir rantai dingin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: Color(0xFF424656),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // close dialog
                    Navigator.pop(context); // back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0050CB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _useCurrentLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLocating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Lokasi saat ini terdeteksi & titik peta diperbarui'),
        backgroundColor: const Color(0xFF0050CB),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildColdChainBanner(),
              const SizedBox(height: 16),
              _buildSavedAddressSection(),
              const SizedBox(height: 16),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFCF9F8),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 56,
      leading: Center(
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1B1B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Lokasi',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1B1B),
              )),
          SizedBox(height: 1),
          Text('Kelola alamat pengirimanmu',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF424656),
              )),
        ],
      ),
    );
  }

  Widget _buildColdChainBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFDAE1FF).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(Icons.ac_unit,
                color: Color(0xFF0050CB), size: 17),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jaminan Suhu Beku -18°C Terjaga',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0050CB),
                    )),
                SizedBox(height: 2),
                Text(
                    'Titik presisi menentukan rute tercepat thermo-box kurir',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF424656),
                      height: 1.4,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSavedAddressSection() {
    final addr = context.watch<AddressProvider>().currentAddress;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE1FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bookmark,
                    size: 14, color: Color(0xFF0050CB)),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00682B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('ALAMAT UTAMA',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF00682B),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 4,
            children: [
              Text(addr.recipientName,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1B1B),
                  )),
              Text('(${addr.phoneNumber})',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: Color(0xFF424656),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text(addr.fullAddress,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                height: 1.625,
                color: Color(0xFF424656),
              )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE1FF).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home,
                        size: 10, color: Color(0xFF0050CB)),
                    const SizedBox(width: 4),
                    Text(addr.label,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0050CB),
                        )),
                  ],
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_outlined,
                      size: 14, color: Color(0xFF00682B)),
                  SizedBox(width: 4),
                  Text('Aktif Pengiriman Frozen',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: Color(0xFF00682B),
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final addr = context.watch<AddressProvider>().currentAddress;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_outlined,
                      size: 18, color: Color(0xFF0050CB)),
                  SizedBox(width: 4),
                  Text('Titik Lokasi',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1B1B),
                      )),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00682B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(color: Color(0xFF00682B)),
                    SizedBox(width: 4),
                    Text('Akurasi Tinggi (GPS)',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: Color(0xFF00682B),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMapCard(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.location_searching,
                      size: 16, color: Color(0xFF0050CB)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(addr.fullAddress,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1B1B),
                          )),
                      const SizedBox(height: 2),
                      Text(addr.coordinateNote,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            height: 1.4,
                            color: Color(0xFF424656),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _mapButton(
                  icon: Icons.edit_location_alt,
                  label: 'Ubah Titik Peta',
                  bg: const Color(0xFFDAE1FF),
                  fg: const Color(0xFF0050CB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _mapButton(
                  icon: Icons.my_location,
                  label: _isLocating ? 'Melacak...' : 'Lokasi Saat Ini',
                  bg: const Color(0xFFF0EDED),
                  fg: const Color(0xFF1C1B1B),
                  onTap: _useCurrentLocation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    VoidCallback? onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 208,
        child: Stack(
          children: [
            Container(color: const Color(0xFFEAEBF3)),
            Positioned(
              left: -40,
              top: 0,
              bottom: 0,
              width: 130,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD3EBD9),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),
            Positioned(
              top: 96,
              left: 0,
              right: 0,
              child:
                  Container(height: 14, color: Colors.white),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 150,
              child:
                  Container(width: 14, color: Colors.white),
            ),
            _building(top: 20, left: 60, w: 70, h: 42),
            _building(top: 24, left: 175, w: 75, h: 38),
            _building(bottom: 20, left: 60, w: 105, h: 48),
            _building(bottom: 18, right: 20, w: 85, h: 55),
            _building(top: 30, right: 10, w: 70, h: 55),
            const Positioned(
              top: 102,
              right: 22,
              child: Text('Jl. Bengkulu',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 8,
                    color: Color(0xFF71788E),
                  )),
            ),
            const Positioned(
              top: 60,
              left: 158,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text('Jl. Raya Darmo',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF525E7A),
                    )),
              ),
            ),
            Positioned(
              top: 44,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0050CB),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text('Hub Cold Ikobana',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ac_unit,
                        size: 12, color: Color(0xFF0050CB)),
                    SizedBox(width: 4),
                    Text('Jangkauan Instan (-18°C) Aktif',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: Color(0xFF1C1B1B),
                        )),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: Icon(Icons.add,
                          size: 16,
                          color: Colors.black.withValues(alpha: 0.75)),
                    ),
                    Container(
                        height: 1, color: const Color(0xFFF0EDED)),
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: Icon(Icons.remove,
                          size: 16,
                          color: Colors.black.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0050CB),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_shipping,
                              size: 10, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Titik Penerimaan Barang',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0050CB)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0050CB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on,
                              size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _building({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double w,
    required double h,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5FB),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assignment_outlined,
                  size: 18, color: Color(0xFF0050CB)),
              SizedBox(width: 4),
              Text('Detail Penerima',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1B1B),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          _label('Nama Penerima'),
          const SizedBox(height: 6),
          _textInput(controller: _nameCtrl, hint: 'Nama lengkap'),
          const SizedBox(height: 12),
          _label('Nomor WhatsApp / Seluler'),
          const SizedBox(height: 6),
          _phoneInput(),
          const SizedBox(height: 4),
          const Text(
            'Diperlukan kurir untuk konfirmasi kedatangan paket beku.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF424656),
            ),
          ),
          const SizedBox(height: 12),
          _label('Alamat Lengkap'),
          const SizedBox(height: 6),
          _textInput(
              controller: _addressCtrl,
              hint: 'Jalan, nomor rumah, kelurahan, kota',
              maxLines: 2),
          const SizedBox(height: 12),
          _label('Label Alamat'),
          const SizedBox(height: 6),
          Row(
            children: List.generate(_labelOptions.length, (i) {
              final isActive = _selectedLabel == i;
              final item = _labelOptions[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: i == _labelOptions.length - 1 ? 0 : 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedLabel = i),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF0050CB)
                            : const Color(0xFFF6F3F2),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'] as IconData,
                              size: 14,
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF424656)),
                          const SizedBox(width: 4),
                          Text(item['label'] as String,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF424656),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Catatan Khusus Kurir Rantai Dingin',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1B1B),
                    )),
              ),
              Row(
                children: const [
                  Icon(Icons.ac_unit,
                      size: 12, color: Color(0xFF0050CB)),
                  SizedBox(width: 2),
                  Text('Wajib Suhu Dingin',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: Color(0xFF0050CB),
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _notesCtrl,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                height: 1.43,
                color: Color(0xFF1C1B1B),
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText:
                    'Pagar hitam nomor 25, letakkan paket di cooler box depan teras...',
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  height: 1.43,
                  color: Color(0xFF909090),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jadikan sebagai Alamat Utama',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1B1B),
                        )),
                    SizedBox(height: 2),
                    Text('Otomatis dipilih saat checkout pesanan beku',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: Color(0xFF424656),
                        )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isPrimary = !_isPrimary),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 28,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: _isPrimary
                        ? const Color(0xFF0050CB)
                        : const Color(0xFFCFD1D6),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _isPrimary
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.info_outline,
                      size: 16, color: Color(0xFF575F6A)),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pastikan penerima atau perwakilan siap menerima produk daging/nugget beku segera setelah kurir tiba agar suhu dingin tetap aman.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      height: 1.6,
                      color: Color(0xFF424656),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1B1B),
        ));
  }

  Widget _textInput({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: Color(0xFF1C1B1B),
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: Color(0xFF909090),
          ),
        ),
      ),
    );
  }

  Widget _phoneInput() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Text('+62',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424656),
              )),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: Color(0xFF1C1B1B),
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '812-3456-7890',
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: Color(0xFF909090),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.phone_outlined,
                size: 16, color: Color(0xFF424656)),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  _Dot(color: Color(0xFF00682B)),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Status: Area Tercover Kurir Rantai Dingin Ikobana',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00682B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveAddress,
                  icon: const Icon(Icons.save_outlined,
                      size: 16, color: Colors.white),
                  label: const Text('Simpan Perubahan Alamat',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0050CB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}