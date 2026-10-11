
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const AplikasiTiket());

const navy = Color(0xFF172554);
const biru = Color(0xFF3155D9);
const latar = Color(0xFFF4F6FC);

// ================= MODEL OOP =================

mixin BisaDiskon on Tiket {
  double hitungHargaDiskon(double persen) =>
      harga * (1 - persen / 100);
}

abstract class Tiket {
  final String nama;
  final double harga;

  Tiket(this.nama, this.harga);

  String deskripsi();
}

class TiketEkonomi extends Tiket {
  TiketEkonomi() : super('Tiket Ekonomi', 100000);

  @override
  String deskripsi() => 'Kursi nyaman untuk perjalananmu';
}

class TiketVIP extends Tiket with BisaDiskon {
  TiketVIP() : super('Tiket VIP', 250000);

  @override
  String deskripsi() => 'Kursi premium dengan layanan spesial';
}

class TiketHabisException implements Exception {
  final String pesan;
  TiketHabisException(this.pesan);

  @override
  String toString() => pesan;
}

// ================= FUNGSI ASYNC =================

Future<List<Tiket>> ambilDaftarTiket() async {
  await Future.delayed(const Duration(seconds: 2));
  return [TiketEkonomi(), TiketVIP()];
}

Future<String> pesanTiket(Tiket tiket) async {
  await Future.delayed(const Duration(seconds: 2));

  if (Random().nextInt(3) == 0) {
    throw TiketHabisException('Maaf, tiket sedang habis!');
  }

  return 'Pemesanan ${tiket.nama} berhasil!';
}

// ================= APLIKASI FLUTTER =================

class AplikasiTiket extends StatelessWidget {
  const AplikasiTiket({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TiketKu',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: latar,
        colorScheme: ColorScheme.fromSeed(seedColor: biru),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: navy,
        ),
      ),
      home: const HalamanTiket(),
    );
  }
}

class HalamanTiket extends StatefulWidget {
  const HalamanTiket({super.key});

  @override
  State<HalamanTiket> createState() => _HalamanTiketState();
}

class _HalamanTiketState extends State<HalamanTiket> {
  late Future<List<Tiket>> daftarTiket;
  late final Stream<int> promoStream;

  bool memesan = false;
  String pesan = '';

  @override
  void initState() {
    super.initState();
    daftarTiket = ambilDaftarTiket();

    promoStream = Stream.periodic(
      const Duration(seconds: 1),
      (i) => 30 - i,
    ).take(31);
  }

  Future<void> prosesPesanan(Tiket tiket) async {
    setState(() {
      memesan = true;
      pesan = 'Sedang memproses pesanan...';
    });

    try {
      pesan = await pesanTiket(tiket);
    } on TiketHabisException catch (e) {
      pesan = e.pesan;
    } catch (e) {
      pesan = 'Terjadi kesalahan: $e';
    } finally {
      if (!mounted) return;

      setState(() => memesan = false);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(pesan),
            backgroundColor: pesan.startsWith('Pemesanan')
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
        );
    }
  }

  Widget kartuTiket(Tiket tiket) {
    final vip = tiket is TiketVIP;
    final harga = vip
        ? tiket.hitungHargaDiskon(10)
        : tiket.harga;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: vip ? const Color(0xFFFFD28A) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: vip
                      ? const Color(0xFFFFF0D6)
                      : const Color(0xFFE7ECFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  vip ? Icons.workspace_premium : Icons.train,
                  color: vip ? Colors.orange.shade800 : biru,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tiket.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tiket.deskripsi(),
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (vip)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8BC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'VIP',
                    style: TextStyle(
                      color: Color(0xFF965500),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(color: Color(0xFFEDF0F7)),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vip)
                      const Text(
                        'Rp250.000',
                        style: TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      'Rp${harga.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (vip)
                      const Text(
                        'Hemat 10%',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: memesan ? null : () => prosesPesanan(tiket),
                style: FilledButton.styleFrom(
                  backgroundColor: biru,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text('Pesan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.confirmation_number, color: biru),
            SizedBox(width: 9),
            Text(
              'TiketKu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [navy, biru],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.white70,
                    size: 36,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Perjalanan dimulai di sini!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih tiket favoritmu dan pesan sekarang.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PROMO STREAMBUILDER
            StreamBuilder<int>(
              stream: promoStream,
              initialData: 30,
              builder: (context, snapshot) {
                final sisa = snapshot.data ?? 30;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1DC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.deepOrange,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Promo Spesial!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: navy,
                              ),
                            ),
                            Text(
                              sisa > 0
                                  ? 'Waktu tersisa: $sisa detik'
                                  : 'Waktu promo telah berakhir',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '10% OFF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 26),

            const Text(
              'Pilih Tiket',
              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Temukan tiket yang sesuai dengan kebutuhanmu.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
            const SizedBox(height: 18),

            // FUTUREBUILDER
            FutureBuilder<List<Tiket>>(
              future: daftarTiket,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(
                      child: CircularProgressIndicator(color: biru),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Text('Gagal memuat tiket.'),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              daftarTiket = ambilDaftarTiket();
                            });
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Belum ada tiket tersedia.'),
                  );
                }

                return Column(
                  children: snapshot.data!
                      .map((tiket) => kartuTiket(tiket))
                      .toList(),
                );
              },
            ),

            if (memesan) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(color: biru),
            ],

            if (pesan.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                pesan,
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Center(
              child: Text(
                'TiketKu • Simulasi Pemesanan Tiket',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

