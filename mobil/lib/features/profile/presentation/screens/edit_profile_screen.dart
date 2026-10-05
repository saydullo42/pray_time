import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.fullName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(profileProvider.notifier).updateProfile(fullName: _nameController.text);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profilni tahrirlash')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'To\'liq ism',
                controller: _nameController,
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Saqlash',
                isLoading: profileAsync.isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
