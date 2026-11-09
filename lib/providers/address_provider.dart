// lib/providers/address_provider.dart
import 'package:flutter/material.dart';

class AddressModel {
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;
  final String label;
  final String notes;
  final bool isPrimary;
  final String coordinateNote;

  AddressModel({
    required this.recipientName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.label,
    this.notes = '',
    this.isPrimary = true,
    this.coordinateNote =
        'Koordinat telah disesuaikan dengan gerbang depan rumah',
  });

  AddressModel copyWith({
    String? recipientName,
    String? phoneNumber,
    String? fullAddress,
    String? label,
    String? notes,
    bool? isPrimary,
    String? coordinateNote,
  }) {
    return AddressModel(
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      label: label ?? this.label,
      notes: notes ?? this.notes,
      isPrimary: isPrimary ?? this.isPrimary,
      coordinateNote: coordinateNote ?? this.coordinateNote,
    );
  }
}

class AddressProvider extends ChangeNotifier {
  AddressModel _currentAddress = AddressModel(
    recipientName: 'Andi Setiawan',
    phoneNumber: '812-3456-7890',
    fullAddress:
        'Jl. Raya Darmo No. 25, Wonokromo, Surabaya, Jawa Timur 60241',
    label: 'Rumah',
    notes:
        'Pagar hitam nomor 25, letakkan paket di cooler box depan teras jika tidak ada orang di rumah.',
    isPrimary: true,
    coordinateNote:
        'Koordinat telah disesuaikan dengan gerbang depan rumah',
  );

  AddressModel get currentAddress => _currentAddress;

  String get displayAddress => _currentAddress.fullAddress;
  String get displayName => _currentAddress.recipientName;
  String get displayPhone => _currentAddress.phoneNumber;
  String get displayLabel => _currentAddress.label;

  void updateAddress(AddressModel newAddress) {
    _currentAddress = newAddress;
    notifyListeners();
  }
}