import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../constants/app_icons.dart';
import '../data/repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';
import '../widgets/app_header.dart';
import '../widgets/app_info_notice.dart';

class RegisterScreen extends StatefulWidget {
  final AuthRepository authRepository;

  RegisterScreen({
    super.key,
    AuthRepository? authRepository,
  }) : authRepository = authRepository ?? AppConfig.authRepository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    setState(() {
      _nameError = Validators.validateName(_nameController.text);
      _emailError = Validators.validateEmail(_emailController.text);
      _phoneError = Validators.validatePhone(_phoneController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmError = Validators.validateConfirmPassword(
        _confirmController.text,
        _passwordController.text,
      );
    });

    if (_nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmError == null) {
      final result = await widget.authRepository.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;

      if (result.isSuccess) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.all(AppTheme.paddingLarge),
            content: const AppInfoNotice(
              message: 'Akun berhasil dibuat. Silakan masuk.',
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        setState(() {
          switch (result.failureType) {
            case AuthFailureType.emailAlreadyRegistered:
              _emailError = 'Email sudah terdaftar.';
              break;
            case AuthFailureType.networkError:
              _confirmError =
                  'Koneksi terputus. Periksa jaringan internet Anda.';
              break;
            case AuthFailureType.serverError:
            default:
              _confirmError =
                  'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
              break;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingXLarge,
            vertical: AppTheme.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(
                title: 'Buat Akun',
                showBackButton: true,
                onBackTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Mulai permainanmu.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 27.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Daftar untuk booking lapangan dengan lebih cepat dan mudah.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 24.0),
              AppField(
                label: 'Nama Lengkap',
                errorText: _nameError,
                trailingIconPath: AppIcons.userRound,
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Arya Habyantara',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              AppField(
                label: 'Email',
                errorText: _emailError,
                trailingIconPath: AppIcons.mail,
                child: TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'email@domain.com',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              AppField(
                label: 'Nomor telepon',
                errorText: _phoneError,
                trailingIconPath: AppIcons.phone,
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_phoneError != null) setState(() => _phoneError = null);
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '081234567890',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              AppField(
                label: 'Password',
                errorText: _passwordError,
                helperText: 'Minimal 8 karakter, gunakan huruf dan angka.',
                trailingIconPath: _obscurePassword ? AppIcons.eyeOff : AppIcons.eye,
                onTrailingTap: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Buat Password Kamu',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              AppField(
                label: 'Konfirmasi password',
                errorText: _confirmError,
                trailingIconPath: _obscureConfirm ? AppIcons.eyeOff : AppIcons.eye,
                onTrailingTap: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
                child: TextField(
                  controller: _confirmController,
                  focusNode: _confirmFocus,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSignUp(),
                  onChanged: (_) {
                    if (_confirmError != null) setState(() => _confirmError = null);
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Masukkan Password Kamu',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const AppInfoNotice(
                message: 'Data pribadimu tersimpan dengan aman.',
              ),
              const SizedBox(height: 24.0),
              AppButton(
                label: 'Daftar',
                onPressed: _handleSignUp,
              ),
              const SizedBox(height: 24.0),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Masuk',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.successForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
