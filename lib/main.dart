import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'constants/colors.dart';
import 'theme/app_theme.dart';
import 'widgets/app_button.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _mataKuliahController = TextEditingController();

  String? _statusKehadiran = 'Hadir';
  bool _isSaving = false;

  // Menyimpan data input ke Firebase Cloud Firestore
  Future<void> simpanData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('praktikum').add({
        'nama': _namaController.text.trim(),
        'nim': _nimController.text.trim(),
        'lokasi': _lokasiController.text.trim(),
        'mata_kuliah': _mataKuliahController.text.trim(),
        'status': _statusKehadiran,
        'waktu': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Kosongkan form setelah data berhasil disimpan
      _formKey.currentState!.reset();
      _namaController.clear();
      _nimController.clear();
      _lokasiController.clear();
      _mataKuliahController.clear();

      setState(() {
        _statusKehadiran = 'Hadir';
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan ke Firebase!'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menyimpan data. Periksa koneksi dan konfigurasi Firebase.',
            ),
            backgroundColor: Colors.red,
          ),
        );

      debugPrint('Error Firebase: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _lokasiController.dispose();
    _mataKuliahController.dispose();
    super.dispose();
  }

  // Widget untuk membuat field input dengan validasi
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.black87), // teks yang diketik
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black54),
        filled: true,
        fillColor: Colors.white, // <-- background field jadi terang
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Aplikasi Noval')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Form Input Data Praktikum',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Isi data mahasiswa dan keterangan kehadiran '
                  'untuk menyimpan data ke Firebase.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                _buildTextField(
                  label: 'Nama',
                  controller: _namaController,
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  label: 'NIM',
                  controller: _nimController,
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Lokasi',
                  controller: _lokasiController,
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Mata Kuliah',
                  controller: _mataKuliahController,
                  icon: Icons.menu_book_outlined,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _statusKehadiran,
                  dropdownColor:
                      Colors.white, // <-- penting! biar menu dropdown ga gelap
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText: 'Keterangan Kehadiran',
                    labelStyle: TextStyle(color: Colors.black54),
                    prefixIcon: Icon(
                      Icons.event_available_outlined,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
                    DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                    DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statusKehadiran = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : simpanData,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Data'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Buka Github Saya',
                    icon: Icons.code,
                    url: 'https://github.com',
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
