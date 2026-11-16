// lib/models/address_model.dart
class AddressModel {
  final String id;
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String street;
  final String village;
  final String district;
  final String city;
  final String province;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isPrimary;

  AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.street,
    required this.village,
    required this.district,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Lainnya',
      recipientName: json['recipientName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      street: json['street'] as String? ?? '',
      village: json['village'] as String? ?? '',
      district: json['district'] as String? ?? '',
      city: json['city'] as String? ?? '',
      province: json['province'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  String get fullAddress => '$street, $village, $district, $city, $province $postalCode';
}