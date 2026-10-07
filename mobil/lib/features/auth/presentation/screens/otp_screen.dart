import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/phone_input_field.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _codeLength = 6;
  static const _resendCooldown = Duration(minutes: 2);

  String _code = '';
  int _secondsRemaining = _resendCooldown.inSeconds;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = _resendCooldown.inSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _formattedCountdown {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0) return;
    await ref.read(authProvider.notifier).requestOtp(widget.phoneNumber);
    if (ref.read(authProvider).valueOrNull is AuthOtpSent) {
      _startResendTimer();
    }
  }

  void _appendDigit(String digit) {
    if (_code.length >= _codeLength) return;
    setState(() => _code += digit);
    if (_code.length == _codeLength) _verify();
  }

  void _backspace() {
    if (_code.isEmpty) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  Future<void> _verify() async {
    if (_code.length != _codeLength) return;
    await ref.read(authProvider.notifier).verifyOtp(
          phoneNumber: widget.phoneNumber,
          code: _code,
        );
    final state = ref.read(authProvider).valueOrNull;
    if (!mounted) return;
    if (state is AuthNeedsRegistration) {
      context.go(RouteNames.register);
    } else if (state is AuthAuthenticated) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tasdiqlash kodi')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${formatUzPhoneNumber(widget.phoneNumber)} telefon raqamiga kelgan kodni kiriting',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _codeLength; i++)
                          Container(
                            width: 44,
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF396E0D),
                                width: i < _code.length ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              i < _code.length ? _code[i] : '',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Tasdiqlash',
                      isLoading: authState.isLoading,
                      onPressed: _verify,
                      fontSize: 18,
                      backgroundColor:
                          isDark ? const Color(0xFF396E0D) : AppColors.lightSurfaceStrong,
                      foregroundColor: Colors.black,
                    ),
                    TextButton(
                      onPressed: _secondsRemaining == 0 ? _resend : null,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF396E0D),
                        disabledForegroundColor:
                            const Color(0xFF396E0D).withValues(alpha: 0.45),
                      ),
                      child: const Text('Kodni qayta yuborish'),
                    ),
                    if (_secondsRemaining > 0)
                      Text(
                        _formattedCountdown,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF396E0D),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 56),
              child: NumericKeypad(
                onDigit: _appendDigit,
                onBackspace: _backspace,
                onSubmit: _verify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
