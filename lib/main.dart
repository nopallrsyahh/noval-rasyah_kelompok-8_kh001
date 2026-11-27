// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'constants/colors.dart';
// import 'theme/app_theme.dart';
// import 'widgets/app_button.dart';
// import 'firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.light,
//       home: const HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _namaController = TextEditingController();
//   final TextEditingController _nimController = TextEditingController();
//   final TextEditingController _lokasiController = TextEditingController();
//   final TextEditingController _mataKuliahController = TextEditingController();

//   String? _statusKehadiran = 'Hadir';
//   bool _isSaving = false;

//   // Menyimpan data input ke Firebase Cloud Firestore
//   Future<void> simpanData() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       await FirebaseFirestore.instance.collection('praktikum').add({
//         'nama': _namaController.text.trim(),
//         'nim': _nimController.text.trim(),
//         'lokasi': _lokasiController.text.trim(),
//         'mata_kuliah': _mataKuliahController.text.trim(),
//         'status': _statusKehadiran,
//         'waktu': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       // Kosongkan form setelah data berhasil disimpan
//       _formKey.currentState!.reset();
//       _namaController.clear();
//       _nimController.clear();
//       _lokasiController.clear();
//       _mataKuliahController.clear();

//       setState(() {
//         _statusKehadiran = 'Hadir';
//       });

//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           const SnackBar(
//             content: Text('Data berhasil disimpan ke Firebase!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Gagal menyimpan data. Periksa koneksi dan konfigurasi Firebase.',
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );

//       debugPrint('Error Firebase: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _namaController.dispose();
//     _nimController.dispose();
//     _lokasiController.dispose();
//     _mataKuliahController.dispose();
//     super.dispose();
//   }

//   // Widget untuk membuat field input dengan validasi
//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       textInputAction: TextInputAction.next,
//       style: const TextStyle(color: Colors.black87), // teks yang diketik
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black54),
//         prefixIcon: Icon(icon, color: Colors.black54),
//         filled: true,
//         fillColor: Colors.white, // <-- background field jadi terang
//         border: const OutlineInputBorder(),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.black26),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: AppColors.primary, width: 2),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) {
//           return '$label wajib diisi';
//         }
//         return null;
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Demo Aplikasi Noval')),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Form Input Data Praktikum',
//                   style: TextStyle(
//                     color: AppColors.textPrimary,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 const Text(
//                   'Isi data mahasiswa dan keterangan kehadiran '
//                   'untuk menyimpan data ke Firebase.',
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 14,
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 _buildTextField(
//                   label: 'Nama',
//                   controller: _namaController,
//                   icon: Icons.person_outline,
//                 ),

//                 const SizedBox(height: 16),

//                 _buildTextField(
//                   label: 'NIM',
//                   controller: _nimController,
//                   icon: Icons.badge_outlined,
//                   keyboardType: TextInputType.number,
//                 ),

//                 const SizedBox(height: 16),

//                 _buildTextField(
//                   label: 'Lokasi',
//                   controller: _lokasiController,
//                   icon: Icons.location_on_outlined,
//                 ),

//                 const SizedBox(height: 16),

//                 _buildTextField(
//                   label: 'Mata Kuliah',
//                   controller: _mataKuliahController,
//                   icon: Icons.menu_book_outlined,
//                 ),

//                 const SizedBox(height: 16),

//                 DropdownButtonFormField<String>(
//                   initialValue: _statusKehadiran,
//                   dropdownColor:
//                       Colors.white, // <-- penting! biar menu dropdown ga gelap
//                   style: const TextStyle(color: Colors.black87),
//                   decoration: const InputDecoration(
//                     labelText: 'Keterangan Kehadiran',
//                     labelStyle: TextStyle(color: Colors.black54),
//                     prefixIcon: Icon(
//                       Icons.event_available_outlined,
//                       color: Colors.black54,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black26),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                         color: AppColors.primary,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   items: const [
//                     DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
//                     DropdownMenuItem(value: 'Izin', child: Text('Izin')),
//                     DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _statusKehadiran = value;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 24),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: _isSaving ? null : simpanData,
//                     icon: _isSaving
//                         ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.cloud_upload_outlined),
//                     label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Data'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 SizedBox(
//                   width: double.infinity,
//                   child: AppButton(
//                     label: 'Buka Github Saya',
//                     icon: Icons.code,
//                     url: 'https://github.com',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// main.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'services/api_service.dart';

import 'models/admin_model.dart';
import 'services/admin_service.dart';

void main() {
  runApp(const MyApp());
}

// ==========================================
// MAIN APP
// ==========================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale locale = const Locale('id');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Method Tester',
      locale: locale,

      supportedLocales: const [Locale('id'), Locale('en')],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      home: HomeScreen(
        onLanguageChanged: (value) {
          setState(() {
            locale = Locale(value);
          });
        },
      ),
    );
  }
}

// ==========================================
// PAGE 1 - USER LIST
// ==========================================

class HomeScreen extends StatefulWidget {
  final Function(String) onLanguageChanged;

  const HomeScreen({super.key, required this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = ApiService.getUsers();
  }

  void refreshData() {
    setState(() {
      futureUsers = ApiService.getUsers();
    });
  }

  Future<void> showJsonLocation() async {
    final path = await ApiService.getJsonFilePath();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Penyimpanan File JSON'),
        content: SelectableText(path),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> resetUsers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data JSON?'),
        content: const Text('Kembalikan data User ke daftar awal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.resetToDefault();

      if (!mounted) return;

      refreshData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data User berhasil di-reset')),
      );
    }
  }

  Widget buildUserList(AppLocalizations language) {
    return FutureBuilder<List<dynamic>>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 12),
                Text(language.errorMessage),
                ElevatedButton(
                  onPressed: refreshData,
                  child: Text(language.retry),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(child: Text(language.noData));
        }

        return RefreshIndicator(
          onRefresh: () async => refreshData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      user['name'].toString().isNotEmpty
                          ? user['name'].toString()[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user['name'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user['email'].toString()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApiTesterScreen(initialId: user['id']),
                      ),
                    ).then((_) => refreshData());
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('API Method Tester'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Lokasi File JSON',
              onPressed: showJsonLocation,
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Reset Data User',
              onPressed: resetUsers,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.language),
              onSelected: widget.onLanguageChanged,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'id',
                  child: Text('Bahasa Indonesia'),
                ),
                const PopupMenuItem(value: 'en', child: Text('English')),
              ],
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: 'Users'),
              Tab(
                icon: Icon(Icons.admin_panel_settings_outlined),
                text: 'Admins',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApiTesterScreen()),
            ).then((_) => refreshData());
          },
          icon: const Icon(Icons.api),
          label: const Text('Test API'),
        ),
        body: TabBarView(
          children: [buildUserList(language), const AdminListScreen()],
        ),
      ),
    );
  }
}

class AdminListScreen extends StatefulWidget {
  const AdminListScreen({super.key});

  @override
  State<AdminListScreen> createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen> {
  late Future<List<Admin>> futureAdmins;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureAdmins = AdminService.getAdmins();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void refreshData() {
    setState(() {
      futureAdmins = AdminService.getAdmins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Daftar Admin.
        Expanded(
          child: FutureBuilder<List<Admin>>(
            future: futureAdmins,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text('Gagal mengambil data Admin: ${snapshot.error}'),
                      ElevatedButton(
                        onPressed: refreshData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              final admins = snapshot.data ?? [];

              if (admins.isEmpty) {
                return const Center(child: Text('Belum ada data Admin'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  refreshData();
                  await futureAdmins;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final admin = admins[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          admin.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'ID: ${admin.id}\n'
                          '${admin.email}\n'
                          '${admin.department}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final deleted = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminDetailScreen(adminId: admin.id),
                            ),
                          );

                          if (deleted == true) {
                            refreshData();
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AdminDetailScreen extends StatefulWidget {
  final int adminId;

  const AdminDetailScreen({super.key, required this.adminId});

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  late Future<Admin> futureAdmin;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    futureAdmin = AdminService.getAdmin(widget.adminId);
  }

  Future<void> deleteAdmin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Admin?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus Admin ID ${widget.adminId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isDeleting = true);

    try {
      final success = await AdminService.deleteAdmin(widget.adminId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin tidak ditemukan')));

        setState(() => isDeleting = false);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isDeleting = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus Admin: $e')));
    }
  }

  Widget buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Admin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Admin>(
        future: futureAdmin,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal mengambil data: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Data Admin tidak ditemukan'));
          }

          final admin = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 45,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  admin.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  'Administrator',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 28),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        buildDetailItem(
                          Icons.numbers,
                          'Admin ID',
                          admin.id.toString(),
                        ),
                        const Divider(),
                        buildDetailItem(
                          Icons.person_outline,
                          'Name',
                          admin.name,
                        ),
                        const Divider(),
                        buildDetailItem(
                          Icons.email_outlined,
                          'Email',
                          admin.email,
                        ),
                        const Divider(),
                        buildDetailItem(
                          Icons.business_outlined,
                          'Department',
                          admin.department,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isDeleting ? null : deleteAdmin,
                    icon: isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(isDeleting ? 'Menghapus...' : 'Hapus Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// PAGE 2 - API METHOD TESTER
// ==========================================


// ==========================================
// PAGE 2 - API METHOD TESTER
// ==========================================

class ApiTesterScreen extends StatefulWidget {
  final int? initialId;

  const ApiTesterScreen({super.key, this.initialId});

  @override
  State<ApiTesterScreen> createState() => _ApiTesterScreenState();
}

class _ApiTesterScreenState extends State<ApiTesterScreen> {
  String selectedResource = 'Users';
  String selectedMethod = 'GET';

  final idController = TextEditingController();
  final nimController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  dynamic result;
  String? errorMessage;

  bool get isAdmin => selectedResource == 'Admins';
  bool get isGet => selectedMethod == 'GET';
  bool get isPost => selectedMethod == 'POST';
  bool get isPut => selectedMethod == 'PUT';
  bool get isPatch => selectedMethod == 'PATCH';
  bool get isDelete => selectedMethod == 'DELETE';

  @override
  void initState() {
    super.initState();

    if (widget.initialId != null) {
      idController.text = widget.initialId.toString();
    }
  }

  @override
  void dispose() {
    idController.dispose();
    nimController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ==========================================
  // RESOURCE & METHOD CONFIGURATION
  // ==========================================

  void changeResource(String? value) {
    if (value == null) return;

    setState(() {
      selectedResource = value;
      selectedMethod = 'GET';

      idController.clear();
      nimController.clear();
      nameController.clear();
      emailController.clear();

      result = null;
      errorMessage = null;
    });
  }

  void changeMethod(String? value) {
    if (value == null) return;

    setState(() {
      selectedMethod = value;

      // ID tetap dipertahankan agar mudah digunakan
      // ketika berpindah dari GET ke PUT, PATCH, atau DELETE.
      nimController.clear();
      nameController.clear();
      emailController.clear();

      result = null;
      errorMessage = null;
    });
  }

  // ==========================================
  // REQUEST VALIDATION
  // ==========================================

  bool validateRequest() {
    final id = int.tryParse(idController.text.trim());

    // GET Admin dapat mengambil seluruh data
    // jika ID tidak diisi.
    final isAdminGetAll =
        isAdmin && isGet && idController.text.trim().isEmpty;

    if (!isPost && !isAdminGetAll && id == null) {
      showMessage(
        'Masukkan ID ${isAdmin ? 'Admin' : 'User'} yang valid.',
      );
      return false;
    }

    // Validasi NIM khusus POST User.
    if (!isAdmin && isPost) {
      final nim = nimController.text.trim();

      if (nim.isEmpty) {
        showMessage('NIM wajib diisi.');
        return false;
      }

      if (!RegExp(r'^\d+$').hasMatch(nim) || nim.length < 3) {
        showMessage(
          'NIM harus berupa angka dan minimal 3 digit.',
        );
        return false;
      }
    }

    // Validasi nama untuk POST, PUT, dan PATCH User.
    if (!isAdmin &&
        !isGet &&
        !isDelete &&
        nameController.text.trim().isEmpty) {
      showMessage('Nama tidak boleh kosong.');
      return false;
    }

    // Validasi email untuk POST dan PUT User.
    if (!isAdmin && (isPost || isPut)) {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        showMessage('Email tidak boleh kosong.');
        return false;
      }

      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        showMessage('Format email tidak valid.');
        return false;
      }
    }

    return true;
  }

  // ==========================================
  // SEND REQUEST
  // ==========================================

  Future<void> sendRequest() async {
    if (isLoading) return;

    if (!validateRequest()) return;

    final id = int.tryParse(idController.text.trim());

    setState(() {
      isLoading = true;
      result = null;
      errorMessage = null;
    });

    try {
      dynamic response;

      if (isAdmin) {
        response = await handleAdminRequest(id);
      } else {
        response = await handleUserRequest(id);
      }

      if (!mounted) return;

      setState(() {
        result = response;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // USER REQUEST HANDLER
  // ==========================================

  Future<dynamic> handleUserRequest(int? id) async {
    switch (selectedMethod) {
      // GET: Mengambil detail User.
      case 'GET':
        return await ApiService.getUser(id!);

      // POST: Menambahkan User baru berdasarkan NIM.
      case 'POST':
        return await ApiService.createUser(
          nim: nimController.text.trim(),
          name: nameController.text.trim(),
          email: emailController.text.trim(),
        );

      // PUT: Memperbarui nama dan email User.
      case 'PUT':
        return await ApiService.updateUser(
          id!,
          nameController.text.trim(),
          emailController.text.trim(),
        );

      // PATCH: Menambahkan suffix pada nama User.
      case 'PATCH':
        final users = await ApiService.getUsers();

        final index = users.indexWhere(
          (user) => user['id'].toString() == id.toString(),
        );

        if (index == -1) {
          throw Exception('User dengan ID $id tidak ditemukan.');
        }

        final currentName = users[index]['name'].toString();

        // Mencegah suffix ditambahkan berulang kali.
        if (currentName.endsWith(' - Flutter Developer')) {
          throw Exception(
            'Nama User sudah memiliki suffix Flutter Developer.',
          );
        }

        return await ApiService.patchUser(
          id!,
          '$currentName - Flutter Developer',
        );

      // DELETE: Menghapus User.
      case 'DELETE':
        final success = await ApiService.deleteUser(id!);

        return {
          'success': success,
          'message': success
              ? 'User berhasil dihapus.'
              : 'User dengan ID $id tidak ditemukan.',
        };

      default:
        throw Exception('HTTP Method tidak didukung.');
    }
  }

  // ==========================================
  // ADMIN REQUEST HANDLER
  // ==========================================

  Future<dynamic> handleAdminRequest(int? id) async {
    switch (selectedMethod) {
      // GET: Mengambil seluruh Admin atau detail Admin.
      case 'GET':
        if (id == null) {
          final admins = await AdminService.getAdmins();

          return admins
              .map(
                (admin) => {
                  'id': admin.id,
                  'name': admin.name,
                  'email': admin.email,
                  'department': admin.department,
                },
              )
              .toList();
        }

        final admin = await AdminService.getAdmin(id);

        return {
          'id': admin.id,
          'name': admin.name,
          'email': admin.email,
          'department': admin.department,
        };

      // DELETE: Menghapus Admin berdasarkan ID.
      case 'DELETE':
        final success = await AdminService.deleteAdmin(id!);

        return {
          'success': success,
          'message': success
              ? 'Admin berhasil dihapus.'
              : 'Admin dengan ID $id tidak ditemukan.',
        };

      default:
        throw Exception('HTTP Method tidak didukung untuk Admin.');
    }
  }

  // ==========================================
  // SNACKBAR
  // ==========================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // ==========================================
  // INFORMATION MESSAGE
  // ==========================================

  String get informationMessage {
    if (isAdmin) {
      if (isGet) {
        return idController.text.trim().isEmpty
            ? 'GET: Mengambil seluruh data Admin. Kosongkan ID untuk melihat semua data.'
            : 'GET: Mengambil detail Admin berdasarkan ID.';
      }

      return 'DELETE: Menghapus data Admin berdasarkan ID.';
    }

    if (isGet) {
      return 'GET: Mengambil detail User berdasarkan ID.';
    }

    if (isPost) {
      return 'POST: Menambahkan User baru. ID ditentukan dari tiga digit terakhir NIM + 1000.';
    }

    if (isPut) {
      return 'PUT: Memperbarui nama dan email User berdasarkan ID.';
    }

    if (isPatch) {
      return 'PATCH: Menambahkan suffix " - Flutter Developer" pada nama User.';
    }

    return 'DELETE: Menghapus data User berdasarkan ID.';
  }

  // ==========================================
  // INPUT LABEL
  // ==========================================

  Widget buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Method Tester'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              'Request Configuration',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Pilih resource dan HTTP method, kemudian '
              'masukkan data yang ingin diproses.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // RESOURCE
            buildInputLabel('Resource'),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedResource,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.storage),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Users',
                  child: Text('Users'),
                ),
                DropdownMenuItem(
                  value: 'Admins',
                  child: Text('Admins'),
                ),
              ],
              onChanged: isLoading ? null : changeResource,
            ),

            const SizedBox(height: 20),

            // HTTP METHOD
            buildInputLabel('HTTP Method'),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.api),
              ),
              items: isAdmin
                  ? const [
                      DropdownMenuItem(
                        value: 'GET',
                        child: Text('GET - Retrieve Data'),
                      ),
                      DropdownMenuItem(
                        value: 'DELETE',
                        child: Text('DELETE - Remove Data'),
                      ),
                    ]
                  : const [
                      DropdownMenuItem(
                        value: 'GET',
                        child: Text('GET - Retrieve Data'),
                      ),
                      DropdownMenuItem(
                        value: 'POST',
                        child: Text('POST - Create Data'),
                      ),
                      DropdownMenuItem(
                        value: 'PUT',
                        child: Text('PUT - Replace Data'),
                      ),
                      DropdownMenuItem(
                        value: 'PATCH',
                        child: Text('PATCH - Update Data'),
                      ),
                      DropdownMenuItem(
                        value: 'DELETE',
                        child: Text('DELETE - Remove Data'),
                      ),
                    ],
              onChanged: isLoading ? null : changeMethod,
            ),

            const SizedBox(height: 20),

            // NIM INPUT: HANYA UNTUK POST USER
            if (!isAdmin && isPost) ...[
              buildInputLabel('NIM'),

              const SizedBox(height: 8),

              TextField(
                controller: nimController,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan NIM lengkap',
                  prefixIcon: Icon(Icons.badge_outlined),
                  helperText:
                      'ID User dihitung dari 1000 + tiga digit terakhir NIM.',
                ),
              ),

              const SizedBox(height: 20),
            ],

            // ID INPUT
            if (!isPost) ...[
              buildInputLabel(
                isAdmin ? 'Admin ID (Opsional untuk GET)' : 'User ID',
              ),

              const SizedBox(height: 8),

              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: isAdmin ? 'Contoh: 2060' : 'Contoh: 1',
                  prefixIcon: const Icon(Icons.numbers),
                  helperText: isAdmin && isGet
                      ? 'Kosongkan untuk mengambil seluruh data Admin.'
                      : null,
                ),
                onChanged: (_) {
                  if (isAdmin && isGet) {
                    setState(() {
                      errorMessage = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),
            ],

            // NAME INPUT
            if (!isAdmin && !isGet && !isDelete) ...[
              buildInputLabel('Name'),

              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan nama pengguna',
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // EMAIL INPUT
            if (!isAdmin && (isPost || isPut)) ...[
              buildInputLabel('Email'),

              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan email pengguna',
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // INFORMATION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      informationMessage,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SEND BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : sendRequest,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isLoading ? 'Sending Request...' : 'Send Request',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // RESPONSE RESULT
            if (result != null || errorMessage != null) ...[
              const Text(
                'Response Result',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: errorMessage != null
                      ? Colors.red.withOpacity(0.08)
                      : Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: errorMessage != null
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                child: SelectableText(
                  errorMessage ??
                      const JsonEncoder.withIndent('  ').convert(result),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
