import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/phone_input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+998');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final normalized = _phoneController.text.replaceAll(' ', '');
    await ref.read(authProvider.notifier).requestOtp(normalized);
    final state = ref.read(authProvider).valueOrNull;
    if (state is AuthOtpSent && mounted) {
      context.push(RouteNames.otp, extra: state.phoneNumber);
    }
  }

  void _appendDigit(String digit) {
    final digits = extractUzPhoneDigits(_phoneController.text);
    if (digits.length >= 9) return;
    final formatted = formatUzPhoneNumber(digits + digit);
    _phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _backspace() {
    final digits = extractUzPhoneDigits(_phoneController.text);
    if (digits.isEmpty) return;
    final formatted = formatUzPhoneNumber(digits.substring(0, digits.length - 1));
    _phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kirish')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Telefon raqamingizni kiriting. ',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      PhoneInputField(
                        controller: _phoneController,
                        validator: Validators.phoneNumber,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        label: 'Tasdiqlash',
                        isLoading: authState.isLoading,
                        onPressed: _submit,
                        fontSize: 18,
                        backgroundColor: const Color(0xFF396E0D),
                        foregroundColor: Colors.black,
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
                  onSubmit: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
