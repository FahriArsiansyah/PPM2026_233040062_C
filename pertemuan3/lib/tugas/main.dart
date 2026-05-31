import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
          // Menggunakan argumen opsional untuk mendeteksi mode Edit
            final argumen = settings.arguments as Catatan?;
            return MaterialPageRoute(
              builder: (_) => TambahCatatanPage(catatanLama: argumen),
            );
          case '/detail':
            final catatan = settings.arguments as Catatan;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: catatan),
            );
        }
        return null;
      },
    );
  }
}

// ==========================================
// MODEL DATA
// ==========================================
class Catatan {
  final String id;
  final String judul;
  final String isi;
  final String kategori;
  final String email; // Fitur 3: Properti baru untuk email pengirim
  final DateTime dibuatPada;

  Catatan({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.email,
    required this.dibuatPada,
  });
}

// ==========================================
// HALAMAN 1: HOME PAGE (STATEFUL)
// ==========================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // STATE 1: Daftar Utama Catatan
  final List<Catatan> _catatan = [
    Catatan(
      id: '1',
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation pada Pertemuan 3.',
      kategori: 'Kuliah',
      email: 'budi@mahasiswa.ac.id',
      dibuatPada: DateTime.now(),
    ),
  ];

  // STATE 2: Fitur Filter Kategori
  String _filterTerpilih = 'Semua';
  final List<String> _opsiFilter = const ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  String _formatTanggal(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Buka Halaman Tambah Catatan Baru
  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() {
        _catatan.add(hasil);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${hasil.judul}" berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Buka Halaman Detail & menerima data balik jika ada aksi Edit/Update di sana
  Future<void> _bukaDetailCatatan(Catatan dataCatatan) async {
    final hasilBalik = await Navigator.pushNamed(context, '/detail', arguments: dataCatatan);

    // Jika hasil balik membawa objek Catatan, artinya user melakukan Edit data
    if (hasilBalik is Catatan) {
      setState(() {
        final index = _catatan.indexWhere((element) => element.id == hasilBalik.id);
        if (index != -1) {
          _catatan[index] = hasilBalik; // Update data lama di list
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil diperbarui!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _hapusCatatan(String id, String judul) {
    setState(() {
      _catatan.removeWhere((item) => item.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Catatan "$judul" telah dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logika Filter: Menyaring data list sebelum dirender ke layar
    final listCatatanTerfilter = _catatan.where((item) {
      if (_filterTerpilih == 'Semua') return true;
      return item.kategori == _filterTerpilih;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // Fitur 2: Dropdown Filter Kategori diletakkan di AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _filterTerpilih,
              underline: const SizedBox(), // Menghilangkan garis bawah default
              icon: const Icon(Icons.filter_list, color: Colors.indigo),
              items: _opsiFilter.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
                );
              }).toList(),
              onChanged: (String? nilaiBaru) {
                if (nilaiBaru != null) {
                  setState(() {
                    _filterTerpilih = nilaiBaru;
                  });
                }
              },
            ),
          )
        ],
      ),
      body: listCatatanTerfilter.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _catatan.isEmpty ? 'Belum ada catatan.' : 'Tidak ada catatan kategori "$_filterTerpilih"',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: listCatatanTerfilter.length,
        itemBuilder: (context, i) {
          final c = listCatatanTerfilter[i];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(c.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Kategori: ${c.kategori} | Oleh: ${c.email}'),
                  Text(_formatTanggal(c.dibuatPada), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _hapusCatatan(c.id, c.judul),
              ),
              onTap: () => _bukaDetailCatatan(c),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        tooltip: 'Tambah Catatan Baru',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// HALAMAN 2: FORM TAMBAH & EDIT (REUSABLE)
// ==========================================
class TambahCatatanPage extends StatefulWidget {
  // Fitur 1: Jika variabel ini dikirim (tidak null), berarti form berjalan dalam mode EDIT
  final Catatan? catatanLama;

  const TambahCatatanPage({super.key, this.catatanLama});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // Fitur 3: Controller untuk Email

  String _kategori = 'Kuliah';
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    // Fitur 1: Mengisi form otomatis jika terdeteksi mode EDIT
    if (widget.catatanLama != null) {
      _judulCtrl.text = widget.catatanLama!.judul;
      _isiCtrl.text = widget.catatanLama!.isi;
      _emailCtrl.text = widget.catatanLama!.email;
      _kategori = widget.catatanLama!.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose(); // Fitur 3: Membersihkan resource controller email
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanData = Catatan(
      // Jika edit gunakan id lama, jika baru gunakan id timestamp unik baru
      id: widget.catatanLama?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      email: _emailCtrl.text.trim(),
      dibuatPada: widget.catatanLama?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanData);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.catatanLama != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Catatan' : 'Tambah Catatan Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul Catatan',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi!';
                if (v.trim().length < 3) return 'Judul minimal berisi 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Fitur 3: Input Field Baru dengan Validasi Regex Email Avançado
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi!';
                // Ekspresi reguler standard untuk mendeteksi kevalidan format penulisan email
                final regexEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!regexEmail.hasMatch(v.trim())) {
                  return 'Format email tidak valid! Contoh: mhs@kampus.com';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Isi catatan tidak boleh kosong!';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: Icon(isEditMode ? Icons.update : Icons.save),
              label: Text(
                isEditMode ? 'Perbarui Catatan' : 'Simpan Catatan',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN 3: DETAIL CATATAN (STATELESS)
// ==========================================
class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;

  const DetailCatatanPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(catatan.judul, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(catatan.kategori, style: const TextStyle(fontWeight: FontWeight.bold)),
                  avatar: const Icon(Icons.label, size: 16),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  '${catatan.dibuatPada.day}/${catatan.dibuatPada.month}/${catatan.dibuatPada.year}',
                  style: TextStyle(color: Colors.grey.shade600),
                )
              ],
            ),
            const SizedBox(height: 8),
            // Menampilkan email pengirim di detail
            Text('Pengirim: ${catatan.email}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
            const Divider(height: 32, thickness: 1.2),
            Text(catatan.isi, style: const TextStyle(fontSize: 16, height: 1.6)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                ),
                // Fitur 1: Tombol Edit ditambahkan di Halaman Detail
                FilledButton.icon(
                  onPressed: () async {
                    // Berpindah ke Halaman TambahCatatanPage dengan membawa data lama (Mode Edit)
                    final hasilEdit = await Navigator.pushNamed(context, '/tambah', arguments: catatan);

                    if (hasilEdit is Catatan && context.mounted) {
                      // Kembalikan objek yang ter-update ke HomePage melalui pop kedua kalinya
                      Navigator.pop(context, hasilEdit);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Catatan'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.amber.shade800),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}