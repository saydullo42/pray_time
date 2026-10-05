import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  String _code = '';

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
                      backgroundColor: const Color(0xFF396E0D),
                      foregroundColor: Colors.black,
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(authProvider.notifier)
                          .requestOtp(widget.phoneNumber),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF396E0D)),
                      child: const Text('Kodni qayta yuborish'),
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
