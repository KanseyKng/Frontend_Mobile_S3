class UserModel {
    final String id;    // Wajib ada
    final String name;    // Wajib ada
    final String? email;   // Boleh null (opsional)
    final int age;    // Wajib ada
    final bool isActive;  // Wajib ada



    // Constructor utama
    UserModel({
    required this.id,
    required this.name,
    this.email, // Tidak required karena nullable
    required this.age,
    required this.isActive,
    });


factory UserModel.fromJson(Map json) {
    return UserModel(
    // Jika json['id'] null, isi dengan string kosong ''
    id: json['id'] as String? ?? '',
    
    name: json['name'] as String? ?? 'Unknown User',
    
    // Karena email nullable, kita tidak perlu nilai default
    email: json['email'] as String?,
    
    age: json['age'] as int? ?? 0,
    
    isActive: json['isActive'] as bool? ?? false,
    );
}

Map toJson() {
    return {
        'id': id,
        'name': name,
        'email': email,
        'age': age,
        'isActive': isActive,
    };
}
}
void main() {
    // Simulasi JSON dari API (ada data yang hilang, misalnya 'id' dan 'email' null)
    Map jsonResponse = {
    'name': 'Budi Santoso',
    'age': 22,
    // 'id', 'email', dan 'isActive' tidak dikirim oleh server
    };

    // Konversi JSON ke Objek (Aplikasi tidak akan crash berkat Null Safety)
    UserModel user = UserModel.fromJson(jsonResponse);

    print('Nama: ${user.name}');    // Output: Budi Santoso
    print('ID: ${user.id}');    // Output: (string kosong)
    print('Status: ${user.isActive}');// Output: false

    // Konversi kembali Objek ke JSON
    print('To JSON: ${user.toJson()}');
}