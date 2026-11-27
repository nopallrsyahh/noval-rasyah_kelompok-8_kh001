import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../utils/session_manager.dart';

class AccountSecurityScreen extends StatefulWidget {
  final String email;
  const AccountSecurityScreen({Key? key, required this.email})
      : super(key: key);

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hideOld = true;
  bool _hideNew = true;
  bool _saving = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final userId = await SessionManager.getUserId();
    final ok = userId != null &&
        await DatabaseHelper.instance
            .changePassword(userId, _oldCtrl.text, _newCtrl.text);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Kata sandi berhasil diubah.'
          : 'Kata sandi lama tidak sesuai.'),
    ));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun & Keamanan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              initialValue: widget.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Ubah Kata Sandi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _oldCtrl,
              obscureText: _hideOld,
              decoration: InputDecoration(
                labelText: 'Kata sandi lama',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _hideOld ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hideOld = !_hideOld),
                ),
              ),
              validator: (v) =>
              (v == null || v.isEmpty) ? 'Wajib diisi.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newCtrl,
              obscureText: _hideNew,
              decoration: InputDecoration(
                labelText: 'Kata sandi baru',
                prefixIcon: const Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(
                      _hideNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hideNew = !_hideNew),
                ),
              ),
              validator: (v) =>
              (v == null || v.length < 6) ? 'Minimal 6 karakter.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Ulangi kata sandi baru',
                prefixIcon: Icon(Icons.lock_reset),
              ),
              validator: (v) =>
              v != _newCtrl.text ? 'Kata sandi tidak sama.' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
              ),
              child: _saving
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
