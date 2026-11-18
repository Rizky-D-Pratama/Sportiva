import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_config.dart';
import '../constants/app_icons.dart';
import '../data/court_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';
import 'admin/admin_shell.dart';
import 'main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepository authRepository;

  LoginScreen({
    super.key,
    AuthRepository? authRepository,
  }) : authRepository = authRepository ?? AppConfig.authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password wajib diisi.';
      } else {
        _passwordError = null;
      }
    });

    if (_emailError == null && _passwordError == null) {
      final result = await widget.authRepository.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        final user = result.data!;
        final targetScreen = user.role == UserRole.admin
            ? const AdminShell()
            : MainShell(repository: FakeCourtRepository());

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => targetScreen,
          ),
          (route) => false,
        );
      } else {
        setState(() {
          switch (result.failureType) {
            case AuthFailureType.invalidCredentials:
              _passwordError = 'Email atau kata sandi salah.';
              break;
            case AuthFailureType.networkError:
              _passwordError =
                  'Koneksi terputus. Periksa jaringan internet Anda.';
              break;
            case AuthFailureType.profileNotFound:
              _passwordError =
                  'Gagal memuat profil pengguna. Silakan hubungi admin.';
              break;
            case AuthFailureType.serverError:
            default:
              _passwordError =
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingXLarge,
                    vertical: AppTheme.paddingLarge,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16.0),
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 57.0,
                                height: 57.0,
                                child: Image.asset(
                                  'assets/images/logo_sportiva.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                'Sportiva',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        Text(
                          'Selamat Datang Kembali',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 27.0,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Masuk untuk melanjutkan.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 32.0),
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
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
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
                          label: 'Password',
                          errorText: _passwordError,
                          trailingIconPath: _obscurePassword ? AppIcons.eyeOff : AppIcons.eye,
                          onTrailingTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
                            onChanged: (_) {
                              if (_passwordError != null) {
                                setState(() => _passwordError = null);
                              }
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
                        const SizedBox(height: 12.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              // Lupa password belum tersedia
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                'Lupa Password?',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colors.successForeground,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        AppButton(
                          label: 'Masuk',
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 24.0),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegisterScreen(
                                        authRepository: widget.authRepository,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    'Daftar sekarang',
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
                        const SizedBox(height: 48.0),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.shieldCheck,
                              width: 16.0,
                              height: 16.0,
                              colorFilter: ColorFilter.mode(
                                colors.textSecondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Booking aman, main lebih nyaman.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
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
}
