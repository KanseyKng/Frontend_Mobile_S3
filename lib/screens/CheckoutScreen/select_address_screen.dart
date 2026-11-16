// lib/screens/CheckoutScreen/select_address_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../screens/KelolaAlamatScreen/kelola_alamat_screen.dart';

class SelectAddressScreen extends StatelessWidget {
  const SelectAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final addresses = provider.addresses;
    final int emptySlots = 3 - addresses.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1B1B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pilih Alamat Pengiriman', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B))),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...addresses.map((addr) => _buildAddressCard(context, addr, provider)),
                  ...List.generate(emptySlots, (index) => _buildEmptySlot(context)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Gunakan Alamat Ini', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel addr, AddressProvider provider) {
    final isSelected = provider.selectedAddress?.id == addr.id;
    return GestureDetector(
      onTap: () => provider.selectAddress(addr),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDAE1FF).withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.transparent),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primary : const Color(0xFF575F6A), size: 20),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: isSelected ? const Color(0xFF0050CB) : const Color(0xFFF0EDED), borderRadius: BorderRadius.circular(999)),
                  child: Text(addr.label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF575F6A))),
                ),
                if (addr.isPrimary) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF7FFC97), borderRadius: BorderRadius.circular(999)),
                    child: const Text('Utama', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF005320))),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => KelolaAlamatScreen(address: addr)));
                  },
                  child: const Text('Ubah', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0050CB))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${addr.recipientName} (${addr.phoneNumber})', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B))),
            const SizedBox(height: 2),
            Text(addr.fullAddress, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF424656))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaAlamatScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E7FF), width: 2),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text('Tambah Alamat Baru', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}