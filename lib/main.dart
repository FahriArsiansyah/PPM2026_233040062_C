import 'package:flutter/material.dart';

import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

String _formatTanggal(DateTime tanggal) {
  const namaBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  final hari = tanggal.day.toString().padLeft(2, '0');
  final bulan = namaBulan[tanggal.month - 1];
  final tahun = tanggal.year;
  final jam = tanggal.hour.toString().padLeft(2, '0');
  final menit = tanggal.minute.toString().padLeft(2, '0');

  return '$hari $bulan $tahun, $jam:$menit';
}

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
  };

  static Catatan fromMap(Map<String, Object?> m) => Catatan(
    id: m['id'] as int?,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    kategori: m['kategori'] as String,
    dibuatPada: DateTime.fromMillisecondsSinceEpoch(m['dibuat_pada'] as int),
  );

  Catatan copyWith({String? judul, String? isi, String? kategori}) => Catatan(
    id: id,
    judul: judul ?? this.judul,
    isi: isi ?? this.isi,
    kategori: kategori ?? this.kategori,
    dibuatPada: dibuatPada,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/form':
            final arg = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => CatatanFormPage(initial: arg as Catatan?),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Catatan>> _futureCatatan;

  @override
  void initState() {
    super.initState();
    _muatUlang();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = DbHelper.instance.getAll();
    });
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    await Navigator.pushNamed(context, '/form', arguments: initial);
    if (!mounted) return;
    _muatUlang();
  }

  Future<void> _bukaDetail(Catatan catatan) async {
    await Navigator.pushNamed(context, '/detail', arguments: catatan);
    if (!mounted) return;
    _muatUlang();
  }

  Future<void> _konfirmasiHapus(Catatan catatan) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('"${catatan.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    await DbHelper.instance.delete(catatan.id!);
    if (!mounted) return;

    _muatUlang();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${catatan.judul}" dihapus')));
  }

  Widget _itemCatatan(Catatan catatan) {
    return Card(
      child: ListTile(
        onTap: () => _bukaDetail(catatan),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          catatan.judul,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(catatan.kategori),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text(_formatTanggal(catatan.dibuatPada)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(catatan.isi, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => _bukaForm(initial: catatan),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus',
              onPressed: () => _konfirmasiHapus(catatan),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? const [];
          if (data.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, index) => _itemCatatan(data[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

class CatatanFormPage extends StatefulWidget {
  final Catatan? initial;

  const CatatanFormPage({super.key, this.initial});

  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;
  late String _kategori;
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  bool get _isEdit => widget.initial != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.initial?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.initial?.isi ?? '');
    _kategori = widget.initial?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);

    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
        );
        await DbHelper.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
        );
        await DbHelper.instance.insert(baru);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Catatan diperbarui' : 'Catatan ditambahkan'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }
                if (value.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi
                  .map(
                    (kategori) => DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori),
                ),
              )
                  .toList(),
              onChanged: _menyimpan
                  ? null
                  : (value) {
                if (value == null) return;
                setState(() => _kategori = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Isi',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(_isEdit ? 'Update Catatan' : 'Simpan Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;

  const DetailCatatanPage({super.key, required this.catatan});

  Future<void> _editCatatan(BuildContext context) async {
    await Navigator.pushNamed(context, '/form', arguments: catatan);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCatatan(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catatan.judul,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(catatan.kategori)),
                Chip(
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text(_formatTanggal(catatan.dibuatPada)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada catatan',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan tombol Tambah untuk membuat catatan pertama kamu.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}