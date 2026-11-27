
import 'package:flutter/material.dart';
import 'kartu_mahasiswa.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kartu Mahasiswa',
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Data Mahasiswa',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green.shade500,
        ),

        // BACKGROUND PASTEL
        // backgroundColor: const Color(0xFFF8F9F8),

        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/background.jpeg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: KartuMahasiswa(
              nama: 'Noval Rasyah Kurnia Putra',
              nim: '20250801060',
              programStudi: 'Teknik Informatika',
            ),
          ),
        ),
      ),
    );
  }
}
