
import 'package:flutter/material.dart';

class KartuMahasiswa extends StatelessWidget {
  final String nama;
  final String nim;
  final String programStudi;

  const KartuMahasiswa({
    super.key,
    required this.nama,
    required this.nim,
    required this.programStudi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.0,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kartu Mahasiswa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Nama',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            nama,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),

          Text(
            'NIM',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            nim,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),

          Text(
            'Program Studi',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            programStudi,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
