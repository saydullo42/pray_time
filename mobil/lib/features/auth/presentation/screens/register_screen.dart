import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

/// Collects the full name for a first-time user right after OTP
/// verification succeeds.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).completeRegistration(_nameController.text);
    final state = ref.read(authProvider).valueOrNull;
    if (state is AuthAuthenticated && mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ro\'yxatdan o\'tish')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ismingizni kiriting'),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'To\'liq ism',
                controller: _nameController,
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Yakunlash',
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
    );
  }
}
