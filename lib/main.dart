// lib/main.dart
import 'package:flutter/material.dart';

// Import widget kartu dari folder widgets
import 'widgets/pricing_card.dart';

// Import UserModel langsung dari folder lib (sesuai folder tree)
import 'user_model.dart';

void main() {
  // Simulasi JSON dari API (sesuai kode yang kamu berikan)
  Map jsonResponse = {
    'name': 'Budi Santoso',
    'age': 22,
    // 'id', 'email', dan 'isActive' tidak dikirim oleh server
  };

  // Konversi JSON ke Objek (Aplikasi tidak akan crash berkat Null Safety)
  UserModel user = UserModel.fromJson(jsonResponse);

  print('=== DATA USER ===');
  print('Nama: ${user.name}');          // Output: Budi Santoso
  print('ID: ${user.id}');              // Output: (string kosong)
  print('Email: ${user.email}');        // Output: null
  print('Umur: ${user.age}');           // Output: 22
  print('Status: ${user.isActive}');    // Output: false
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
      theme: ThemeData(primarySwatch: Colors.green),
      home: const BerandaScreen(),
    );
  }
}

// ============================================================
// SCREEN 1: BERANDA / KATALOG (StatelessWidget)
// ============================================================
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  // Data katalog produk (3 card)
  final List<Map<String, String>> produkList = const [
    {
      'nama': 'Nugget Ayam Premium',
      'harga': 'Rp 35.000',
      'deskripsi':
          'Nugget ayam premium dari daging ayam pilihan, tanpa pengawet. Cocok untuk lauk praktis keluarga. Berat bersih 500 gram.',
    },
    {
      'nama': 'Sosis Sapi Jumbo',
      'harga': 'Rp 42.000',
      'deskripsi':
          'Sosis sapi jumbo dengan tekstur kenyal dan rasa gurih. Ideal untuk sarapan, bekal anak, atau BBQ keluarga. Isi 10 pcs.',
    },
    {
      'nama': 'Dimsum Mentai Premium',
      'harga': 'Rp 28.000',
      'deskripsi':
          'Dimsum mentai premium dengan saus mentai creamy. Tinggal kukus 10 menit, siap disajikan. Isi 8 pcs.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ikobana Frozen Food'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: produkList.length,
        itemBuilder: (context, index) {
          final produk = produkList[index];
          return PricingCard(
            name: produk['nama']!,
            price: produk['harga']!,
            // Event & State: Navigator.push untuk pindah Screen
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(produk: produk),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// SCREEN 2: DETAIL KATALOG (StatefulWidget)
// ============================================================
class DetailScreen extends StatefulWidget {
  final Map<String, String> produk;

  const DetailScreen({super.key, required this.produk});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // State interaktif: jumlah item yang ingin dibeli
  int jumlah = 1;
  // State interaktif: status favorit
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produk['nama']!),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        // Tombol back otomatis muncul dari AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Gambar / Icon Produk =====
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.green.shade50,
              child: const Icon(
                Icons.fastfood,
                size: 100,
                color: Colors.green,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Text: Nama Produk =====
                  Text(
                    widget.produk['nama']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ===== Text: Harga =====
                  Text(
                    widget.produk['harga']!,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== Container Pastel: Deskripsi =====
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
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.produk['deskripsi']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== State Interaktif: Jumlah Item =====
                  Row(
                    children: [
                      const Text(
                        'Jumlah:',
                        style: TextStyle(
                          fontSize: 16,
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
                  const SizedBox(height: 16),

                  // ===== Tombol Favorit (State Interaktif) =====
                  OutlinedButton.icon(
                    onPressed: toggleFavorit,
                    icon: Icon(
                      isFavorit ? Icons.favorite : Icons.favorite_border,
                      color: isFavorit ? Colors.red : Colors.grey,
                    ),
                    label: Text(
                      isFavorit ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}