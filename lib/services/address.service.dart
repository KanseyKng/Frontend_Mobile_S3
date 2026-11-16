// lib/services/address.service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/address_model.dart';

class AddressService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String get _baseUrl => AppConfig.apiUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AddressModel>> getAddresses() async {
    final res = await http.get(Uri.parse('$_baseUrl/addresses'), headers: await _getHeaders());
    final json = jsonDecode(res.body);
    if (res.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List).map((e) => AddressModel.fromJson(e)).toList();
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
    final res = await http.post(
      Uri.parse('$_baseUrl/addresses'),
      headers: await _getHeaders(),
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
    final res = await http.put(
      Uri.parse('$_baseUrl/addresses/${address.id}'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteAddress(String id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/addresses/$id'),
      headers: await _getHeaders(),
    );
    return res.statusCode == 200;
  }
}