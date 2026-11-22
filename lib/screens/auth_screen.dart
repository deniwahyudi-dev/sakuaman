import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/saku_theme.dart';
import 'main_tab_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const AuthScreen({super.key, required this.isDark, required this.onThemeChanged});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    String? error;
    if (_isLogin) {
      error = await AuthService.instance.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      error = await AuthService.instance.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    if (error == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => MainTabScreen(initialIsDark: widget.isDark)),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBg = widget.isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: widget.isDark ? const Color(0xFF060912) : const Color(0xFFF6F8FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          _isLogin ? "Selamat datang\nkembali" : "Buat akun\nSakuAman",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 40),
                        if (!_isLogin) ...[
                          _buildField("Nama Lengkap", _nameController, false),
                          const SizedBox(height: 20),
                        ],
                        _buildField("Email", _emailController, false, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 20),
                        _buildField("Password", _passwordController, true, textInputAction: TextInputAction.done),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CupertinoActivityIndicator(color: Colors.white)
                                : Text(_isLogin ? "Masuk" : "Daftar", style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = !_isLogin),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: secondaryTextColor, fontSize: 14),
                                children: [
                                  TextSpan(text: _isLogin ? "Belum punya akun? " : "Sudah punya akun? "),
                                  TextSpan(
                                    text: _isLogin ? "Daftar" : "Masuk",
                                    style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, bool isPassword, {TextInputType? keyboardType, TextInputAction? textInputAction}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: TextStyle(color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            keyboardType: keyboardType,
            textInputAction: textInputAction ?? TextInputAction.next,
            style: TextStyle(color: widget.isDark ? Colors.white : const Color(0xFF0F172A)),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(_obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
