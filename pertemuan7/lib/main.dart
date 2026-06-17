import 'package:flutter/material.dart';

import 'api_client.dart';

void main() {
  runApp(const MyApp());
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

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'judul': judul,
      'isi': isi,
      'kategori': kategori,
      'dibuat_pada': dibuatPada.toUtc().toIso8601String(),
    };
  }

  static Catatan fromJson(Map<String, dynamic> map) {
    return Catatan(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      isi: map['isi'] as String,
      kategori: map['kategori'] as String,
      dibuatPada: DateTime.parse(map['dibuat_pada'] as String),
    );
  }

  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
  }) {
    return Catatan(
      id: id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      kategori: kategori ?? this.kategori,
      dibuatPada: dibuatPada,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan REST API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
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
      _futureCatatan = ApiClient.instance.getAll();
    });
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatanPage(initial: initial),
      ),
    );

    if (result == true) {
      _muatUlang();
    }
  }

  Future<void> _bukaDetail(Catatan catatan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailCatatanPage(catatan: catatan),
      ),
    );

    if (result == true) {
      _muatUlang();
    }
  }

  Future<void> _hapusCatatan(Catatan catatan) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Catatan'),
          content: Text('Yakin mau hapus "${catatan.judul}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (yakin == true) {
      try {
        await ApiClient.instance.delete(catatan.id!);

        if (!mounted) return;

        _muatUlang();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${catatan.judul}" dihapus')),
        );
      } on ApiException catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${e.message}')),
        );
      }
    }
  }

  String _formatTanggal(DateTime date) {
    final d = date.toLocal();

    String duaDigit(int n) => n.toString().padLeft(2, '0');

    return '${duaDigit(d.day)}-${duaDigit(d.month)}-${d.year} '
        '${duaDigit(d.hour)}:${duaDigit(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan REST API'),
        actions: [
          IconButton(
            onPressed: _muatUlang,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final pesan = error is ApiException
                ? error.message
                : 'Terjadi kesalahan: $error';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pesan,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _muatUlang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.note_alt_outlined,
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada catatan',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tekan tombol + untuk menambahkan catatan baru.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _bukaForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Catatan'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _muatUlang();
              await _futureCatatan;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final c = data[index];

                return Card(
                  child: ListTile(
                    onTap: () => _bukaDetail(c),
                    title: Text(
                      c.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${c.kategori} • ${_formatTanggal(c.dibuatPada)}\n${c.isi}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    leading: CircleAvatar(
                      child: Text(
                        c.kategori.isNotEmpty
                            ? c.kategori[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _bukaForm(initial: c);
                        } else if (value == 'hapus') {
                          _hapusCatatan(c);
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'hapus',
                            child: Text('Hapus'),
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormCatatanPage extends StatefulWidget {
  final Catatan? initial;

  const FormCatatanPage({
    super.key,
    this.initial,
  });

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;

  final List<String> _kategoriList = [
    'Umum',
    'Tugas',
    'Kuliah',
    'Pribadi',
  ];

  late String _kategori;
  bool _menyimpan = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();

    _judulCtrl = TextEditingController(
      text: widget.initial?.judul ?? '',
    );

    _isiCtrl = TextEditingController(
      text: widget.initial?.isi ?? '',
    );

    final kategoriAwal = widget.initial?.kategori ?? 'Umum';

    if (!_kategoriList.contains(kategoriAwal)) {
      _kategoriList.add(kategoriAwal);
    }

    _kategori = kategoriAwal;
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _menyimpan = true;
    });

    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
        );

        await ApiClient.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
        );

        await ApiClient.instance.insert(baru);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Catatan diperbarui' : 'Catatan ditambahkan',
          ),
        ),
      );

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _menyimpan = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _menyimpan = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: AbsorbPointer(
        absorbing: _menyimpan,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _judulCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _kategori,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: _kategoriList.map((kategori) {
                    return DropdownMenuItem(
                      value: kategori,
                      child: Text(kategori),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _kategori = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _isiCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Isi catatan tidak boleh kosong';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _menyimpan ? null : _simpan,
                    icon: _menyimpan
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.save),
                    label: Text(
                      _menyimpan
                          ? 'Menyimpan...'
                          : _isEdit
                          ? 'Update'
                          : 'Simpan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailCatatanPage extends StatefulWidget {
  final Catatan catatan;

  const DetailCatatanPage({
    super.key,
    required this.catatan,
  });

  @override
  State<DetailCatatanPage> createState() => _DetailCatatanPageState();
}

class _DetailCatatanPageState extends State<DetailCatatanPage> {
  late Catatan _catatan;

  @override
  void initState() {
    super.initState();
    _catatan = widget.catatan;
  }

  String _formatTanggal(DateTime date) {
    final d = date.toLocal();

    String duaDigit(int n) => n.toString().padLeft(2, '0');

    return '${duaDigit(d.day)}-${duaDigit(d.month)}-${d.year} '
        '${duaDigit(d.hour)}:${duaDigit(d.minute)}';
  }

  Future<void> _editCatatan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatanPage(initial: _catatan),
      ),
    );

    if (result == true) {
      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  Future<void> _hapusCatatan() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Catatan'),
          content: Text('Yakin mau hapus "${_catatan.judul}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (yakin == true) {
      try {
        await ApiClient.instance.delete(_catatan.id!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${_catatan.judul}" dihapus')),
        );

        Navigator.pop(context, true);
      } on ApiException catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            onPressed: _editCatatan,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _hapusCatatan,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _catatan.judul,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(_catatan.kategori),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTanggal(_catatan.dibuatPada),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            _catatan.isi,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}