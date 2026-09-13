// lib/main.dart
import 'package:flutter/material.dart';

// Import widget kartu dari folder widgets
import 'widgets/pricing_card.dart';

// Import UserModel dari folder yang sama (lib/)
import 'user_model.dart';

void main() {
  // === Simulasi JSON dari API (log UserModel tetap dipertahankan) ===
  Map jsonResponse = {
    'name': 'Budi Santoso',
    'age': 22,
  };

  UserModel user = UserModel.fromJson(jsonResponse);

  print('=== DATA USER ===');
  print('Nama: ${user.name}');
  print('ID: ${user.id}');
  print('Email: ${user.email}');
  print('Umur: ${user.age}');
  print('Status: ${user.isActive}');
  print('To JSON: ${user.toJson()}');
  print('=================');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ikobana Frozen Food',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const BerandaScreen(),
    );
  }
}

// ============================================================
// SCREEN 1: BERANDA / KATALOG
// WAJIB: StatelessWidget + ListView + 3 Cards + ListTile clickable
// ============================================================
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  // Data 3 produk
  List<Map<String, dynamic>> get _produkList => [
        {
          'id': 'P001',
          'nama': 'Nugget Ayam Premium',
          'harga': 'Rp 35.000',
          'kategori': 'Olahan Ayam',
          'deskripsi':
              'Nugget ayam premium dari daging ayam pilihan tanpa pengawet. Cocok untuk lauk praktis keluarga. Sudah tersertifikasi halal dan BPOM.',
          'expired': '12 bulan (freezer -18°C)',
          'berat': '500 gram',
          'isPromo': true,
        },
        {
          'id': 'P002',
          'nama': 'Sosis Sapi Jumbo',
          'harga': 'Rp 42.000',
          'kategori': 'Olahan Sapi',
          'deskripsi':
              'Sosis sapi jumbo dengan tekstur kenyal dan rasa gurih. Ideal untuk sarapan, bekal anak, atau BBQ keluarga. Isi 10 pcs per pack.',
          'expired': '9 bulan (freezer -18°C)',
          'berat': '600 gram',
          'isPromo': false,
        },
        {
          'id': 'P003',
          'nama': 'Dimsum Mentai Premium',
          'harga': 'Rp 28.000',
          'kategori': 'Dimsum',
          'deskripsi':
              'Dimsum mentai premium dengan saus mentai creamy. Tinggal kukus 10 menit, siap disajikan. Isi 8 pcs per box.',
          'expired': '6 bulan (freezer -18°C)',
          'berat': '320 gram',
          'isPromo': true,
        },
      ];

  @override
  Widget build(BuildContext context) {
    final products = _produkList;

    return Scaffold(
      // AppBar WAJIB (agar tombol back otomatis tersedia di screen 2)
      appBar: AppBar(
        title: const Text('Ikobana Frozen Food'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // ListView berisi 3 Cards
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Promo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD), // pastel biru
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(Icons.local_offer, color: Colors.blue, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promo Hari Ini!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Diskon hingga 20% untuk produk pilihan',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Katalog Produk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 3 Cards menggunakan PricingCard (ListTile) yang bisa diklik
          ...products.map((produk) {
            return PricingCard(
              nama: produk['nama'] as String,
              harga: produk['harga'] as String,
              kategori: produk['kategori'] as String,
              isPromo: produk['isPromo'] as bool,
              onTap: () {
                // NAVIGASI: Stack Navigation (Navigator.push) - SESUAI REQUIREMENT
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(produk: produk),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// SCREEN 2: DETAIL KATALOG
// WAJIB: StatefulWidget + layout Column + Container pastel + padding
// ============================================================
class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> produk;

  const DetailScreen({super.key, required this.produk});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // State interaktif
  int jumlah = 1;
  bool isFavorit = false;

  void tambahJumlah() {
    setState(() {
      jumlah++;
    });
  }

  void kurangJumlah() {
    setState(() {
      if (jumlah > 1) jumlah--;
    });
  }

  void toggleFavorit() {
    setState(() {
      isFavorit = !isFavorit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final produk = widget.produk;

    return Scaffold(
      // AppBar dengan tombol back otomatis
      appBar: AppBar(
        title: Text(produk['nama'] as String),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      // Layout vertikal dengan Column
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon/gambar produk
            Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFE8F5E9), // pastel hijau
              child: const Icon(
                Icons.ac_unit,
                size: 100,
                color: Colors.green,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text nama produk
                  Text(
                    produk['nama'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Chip kategori
                  Row(
                    children: [
                      Chip(
                        label: Text(produk['kategori'] as String),
                        backgroundColor: const Color(0xFFE8F5E9),
                        labelStyle: const TextStyle(color: Colors.green),
                      ),
                      if (produk['isPromo'] as bool) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: const Text('PROMO'),
                          backgroundColor: const Color(0xFFFFCDD2),
                          labelStyle: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Text harga
                  Text(
                    produk['harga'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Container warna pastel + padding untuk DESKRIPSI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0), // pastel orange
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          produk['deskripsi'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Container warna pastel + padding untuk INFO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), // pastel biru
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Masa Simpan: ${produk['expired']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.scale,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Berat Bersih: ${produk['berat']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // State interaktif: Jumlah
                  Row(
                    children: [
                      const Text(
                        'Jumlah:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: kurangJumlah,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.green,
                      ),
                      Text(
                        '$jumlah',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: tambahJumlah,
                        icon: const Icon(Icons.add_circle_outline),
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // State interaktif: Favorit
                  OutlinedButton.icon(
                    onPressed: toggleFavorit,
                    icon: Icon(
                      isFavorit ? Icons.favorite : Icons.favorite_border,
                      color: isFavorit ? Colors.red : Colors.grey,
                    ),
                    label: Text(
                      isFavorit
                          ? 'Hapus dari Favorit'
                          : 'Tambah ke Favorit',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Beli
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Berhasil menambahkan $jumlah ${produk['nama']} ke keranjang',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        'Tambah ke Keranjang • ${produk['harga']}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}