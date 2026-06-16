import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class ProfileData {
  String nama;
  String bio;
  String pendidikan;
  String lokasi;
  String kontak;
  String skills;
  Uint8List? fotoProfilBytes;

  ProfileData({
    required this.nama,
    required this.bio,
    required this.pendidikan,
    required this.lokasi,
    required this.kontak,
    required this.skills,
    this.fotoProfilBytes,
  });
}

class ExperienceData {
  String judul;
  String deskripsi;
  Uint8List? gambarBytes;

  ExperienceData({
    required this.judul,
    required this.deskripsi,
    this.gambarBytes,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profil Saya',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  ProfileData profile = ProfileData(
    nama: 'Fahri Arsiansyah',
    bio: 'Mahasiswa Teknik Informatika',
    pendidikan: 'Teknik Informatika - Semester 6',
    lokasi: 'Bandung, Jawa Barat',
    kontak: 'fahriarsiansyah@gmail.com',
    skills: 'Flutter, Dart, Java, PHP, Git',
  );

  ExperienceData experience = ExperienceData(
    judul: 'Project Mobile',
    deskripsi: 'Membuat aplikasi profil menggunakan Flutter.',
  );

  Future<void> bukaEditProfil() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(profile: profile),
      ),
    );

    if (result != null && result is ProfileData) {
      setState(() {
        profile = result;
      });
    }
  }

  Future<void> bukaEditPengalaman() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditExperiencePage(experience: experience),
      ),
    );

    if (result != null && result is ExperienceData) {
      setState(() {
        experience = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f2ff),
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: const Color(0xffeee9ff),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
              ),
              child: Text(
                'Menu Utama',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profil'),
              onTap: () {
                Navigator.pop(context);
                bukaEditProfil();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Upload Pengalaman'),
              onTap: () {
                Navigator.pop(context);
                bukaEditPengalaman();
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerProfile(),
          const SizedBox(height: 16),
          _infoCard(Icons.info, 'Tentang', profile.bio),
          _infoCard(Icons.school, 'Pendidikan', profile.pendidikan),
          _infoCard(Icons.location_on, 'Lokasi', profile.lokasi),
          _infoCard(Icons.email, 'Kontak', profile.kontak),
          _skillsCard(),
          _experienceCard(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profil'),
        onPressed: bukaEditProfil,
      ),
    );
  }

  Widget _headerProfile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: profile.fotoProfilBytes != null
                  ? MemoryImage(profile.fotoProfilBytes!)
                  : null,
              child: profile.fotoProfilBytes == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              profile.nama,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(profile.bio),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('12\nPost', textAlign: TextAlign.center),
                Text('128\nTeman', textAlign: TextAlign.center),
                Text('1.2K\nLike', textAlign: TextAlign.center),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _skillsCard() {
    final skillList = profile.skills.split(',');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text('Skills'),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skillList
                  .map(
                    (skill) => Chip(
                  label: Text(skill.trim()),
                  side: const BorderSide(color: Colors.deepPurple),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _experienceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.work, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text('Pengalaman'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(10),
                    image: experience.gambarBytes != null
                        ? DecorationImage(
                      image: MemoryImage(experience.gambarBytes!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: experience.gambarBytes == null
                      ? const Icon(Icons.image, color: Colors.deepPurple)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.judul,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(experience.deskripsi),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final ProfileData profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker picker = ImagePicker();

  late TextEditingController namaController;
  late TextEditingController bioController;
  late TextEditingController pendidikanController;
  late TextEditingController lokasiController;
  late TextEditingController kontakController;
  late TextEditingController skillsController;

  Uint8List? fotoBaruBytes;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.profile.nama);
    bioController = TextEditingController(text: widget.profile.bio);
    pendidikanController =
        TextEditingController(text: widget.profile.pendidikan);
    lokasiController = TextEditingController(text: widget.profile.lokasi);
    kontakController = TextEditingController(text: widget.profile.kontak);
    skillsController = TextEditingController(text: widget.profile.skills);
    fotoBaruBytes = widget.profile.fotoProfilBytes;
  }

  Future<void> pilihFoto() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();

      setState(() {
        fotoBaruBytes = bytes;
      });
    }
  }

  void simpanProfil() {
    final dataBaru = ProfileData(
      nama: namaController.text,
      bio: bioController.text,
      pendidikan: pendidikanController.text,
      lokasi: lokasiController.text,
      kontak: kontakController.text,
      skills: skillsController.text,
      fotoProfilBytes: fotoBaruBytes,
    );

    Navigator.pop(context, dataBaru);
  }

  @override
  void dispose() {
    namaController.dispose();
    bioController.dispose();
    pendidikanController.dispose();
    lokasiController.dispose();
    kontakController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f2ff),
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: const Color(0xffeee9ff),
        actions: [
          TextButton.icon(
            onPressed: simpanProfil,
            icon: const Icon(Icons.check),
            label: const Text('Simpan'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Text(
              'Foto Profil',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: fotoBaruBytes != null
                      ? MemoryImage(fotoBaruBytes!)
                      : null,
                  child: fotoBaruBytes == null
                      ? const Icon(Icons.person, size: 55)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: pilihFoto,
                    child: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: pilihFoto,
            icon: const Icon(Icons.image),
            label: const Text('Ganti Foto dari Galeri'),
          ),
          const Divider(height: 30),
          const Text(
            'Informasi Profil',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _input(namaController, 'Nama Lengkap', Icons.person),
          _input(bioController, 'Bio / Tentang', Icons.info, maxLines: 3),
          _input(pendidikanController, 'Pendidikan', Icons.school),
          _input(lokasiController, 'Lokasi', Icons.location_on),
          _input(kontakController, 'Kontak', Icons.email),
          _input(skillsController, 'Skills', Icons.star),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: simpanProfil,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Perubahan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class EditExperiencePage extends StatefulWidget {
  final ExperienceData experience;

  const EditExperiencePage({super.key, required this.experience});

  @override
  State<EditExperiencePage> createState() => _EditExperiencePageState();
}

class _EditExperiencePageState extends State<EditExperiencePage> {
  final ImagePicker picker = ImagePicker();

  late TextEditingController judulController;
  late TextEditingController deskripsiController;

  Uint8List? gambarBaruBytes;

  @override
  void initState() {
    super.initState();
    judulController = TextEditingController(text: widget.experience.judul);
    deskripsiController =
        TextEditingController(text: widget.experience.deskripsi);
    gambarBaruBytes = widget.experience.gambarBytes;
  }

  Future<void> pilihGambar() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();

      setState(() {
        gambarBaruBytes = bytes;
      });
    }
  }

  void simpanPengalaman() {
    final dataBaru = ExperienceData(
      judul: judulController.text,
      deskripsi: deskripsiController.text,
      gambarBytes: gambarBaruBytes,
    );

    Navigator.pop(context, dataBaru);
  }

  @override
  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f2ff),
      appBar: AppBar(
        title: const Text('Upload Pengalaman'),
        backgroundColor: const Color(0xffeee9ff),
        actions: [
          TextButton.icon(
            onPressed: simpanPengalaman,
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: pilihGambar,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade100),
                image: gambarBaruBytes != null
                    ? DecorationImage(
                  image: MemoryImage(gambarBaruBytes!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: gambarBaruBytes == null
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 45,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(height: 8),
                  Text('Ketuk untuk pilih gambar'),
                  Text(
                    'Pilih galeri pengalaman kamu',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Informasi Pengalaman',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: judulController,
            decoration: InputDecoration(
              labelText: 'Judul',
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: deskripsiController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: simpanPengalaman,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Pengalaman'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}