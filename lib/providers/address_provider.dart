// lib/providers/address_provider.dart
import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address.service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _service = AddressService();

  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _error;

  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AddressModel get currentAddress => _selectedAddress ?? (_addresses.isNotEmpty
      ? _addresses.first
      : AddressModel(
          id: '',
          label: 'Belum ada',
          recipientName: '',
          phoneNumber: '',
          street: '',
          village: '',
          district: '',
          city: '',
          province: '',
          postalCode: '',
          latitude: 0,
          longitude: 0,
          isPrimary: false,
        ));

  String get displayAddress => currentAddress.fullAddress;
  String get displayName => currentAddress.recipientName;
  String get displayPhone => currentAddress.phoneNumber;
  String get displayLabel => currentAddress.label;

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _service.getAddresses();
      if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.firstWhere((a) => a.isPrimary, orElse: () => _addresses.first);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<String?> saveAddress(AddressModel address, {bool isNew = false}) async {
    try {
      bool success;
      if (isNew) {
        success = await _service.createAddress(address);
      } else {
        success = await _service.updateAddress(address);
      }
      if (success) {
        await fetchAddresses();
        return null;
      }
      return 'Gagal menyimpan alamat';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteAddress(String id) async {
    try {
      final success = await _service.deleteAddress(id);
      if (success) {
        await fetchAddresses();
        return null;
      }
      return 'Gagal menghapus alamat';
    } catch (e) {
      return e.toString();
    }
  }

  void clear() {
    _addresses.clear();
    _selectedAddress = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}