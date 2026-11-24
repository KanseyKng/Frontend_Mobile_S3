// lib/services/address.service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/address_model.dart';
import '../utils/api_headers.dart';

class AddressService {
  String get _baseUrl => AppConfig.apiUrl;

  Future<List<AddressModel>> getAddresses() async {
    final headers = await ApiHeaders.get();
    final res = await http.get(
      Uri.parse('$_baseUrl/addresses'),
      headers: headers,
    );
    final json = jsonDecode(res.body);
    if (res.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => AddressModel.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal mengambil alamat');
  }

  Future<bool> createAddress(AddressModel address) async {
    final body = {
      'label': address.label,
      'recipientName': address.recipientName,
      'phoneNumber': address.phoneNumber,
      'street': address.street,
      'village': address.village,
      'district': address.district,
      'city': address.city,
      'province': address.province,
      'postalCode': address.postalCode,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'isPrimary': address.isPrimary,
    };
    final headers = await ApiHeaders.get();
    final res = await http.post(
      Uri.parse('$_baseUrl/addresses'),
      headers: headers,
      body: jsonEncode(body),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateAddress(AddressModel address) async {
    final body = {
      'label': address.label,
      'recipientName': address.recipientName,
      'phoneNumber': address.phoneNumber,
      'street': address.street,
      'village': address.village,
      'district': address.district,
      'city': address.city,
      'province': address.province,
      'postalCode': address.postalCode,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'isPrimary': address.isPrimary,
    };
    final headers = await ApiHeaders.get();
    final res = await http.put(
      Uri.parse('$_baseUrl/addresses/${address.id}'),
      headers: headers,
      body: jsonEncode(body),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteAddress(String id) async {
    final headers = await ApiHeaders.get();
    final res = await http.delete(
      Uri.parse('$_baseUrl/addresses/$id'),
      headers: headers,
    );
    return res.statusCode == 200;
  }
}