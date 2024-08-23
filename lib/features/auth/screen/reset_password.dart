import 'package:flutter/material.dart';
import 'package:flutter_boilerplate_hng11/features/auth/widgets/chevron_back_button.dart';
import 'package:flutter_boilerplate_hng11/features/auth/providers/auth.provider.dart';
import 'package:flutter_boilerplate_hng11/utils/global_colors.dart';
import 'package:flutter_boilerplate_hng11/utils/validator.dart';
import 'package:flutter_boilerplate_hng11/utils/widgets/custom_button.dart';
import 'package:flutter_boilerplate_hng11/utils/widgets/password_textfield.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  const ResetPassword({super.key, required this.email});
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}
class _ResetPasswordState extends State<ResetPassword> {
  bool loading = false;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final _formResetKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  void _startTimer() {}
  Future<void> _handleResetPassword(WidgetRef ref, BuildContext context) async {
    setState(() {
      loading = true;
    });
    final newPassword = _newPasswordController.text;
    final confirmNewPassword = _confirmPasswordController.text;
    await ref
        .read(authProvider.notifier)
        .resetPassword(widget.email, newPassword, confirmNewPassword, context);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ChevronBackButton(),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.sp),
            child: Form(
              key: _formResetKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.resetPasswordTitle,
                    style: TextStyle(
                      color: GlobalColors.darkOne,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    AppLocalizations.of(context)!.resetPasswordDescription,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 28.sp),
                  PasswordTextField(
                    label: AppLocalizations.of(context)!.newPassword,
                    controller: _newPasswordController,
                    obscureText: true,
                    hintText: AppLocalizations.of(context)!.enterNewPassword,
                    validator: Validators.passwordValidator,
                  ),
                  SizedBox(height: 16.sp),
                  PasswordTextField(
                    label: AppLocalizations.of(context)!.confirmPassword,
                    controller: _confirmPasswordController,
                    obscureText: true,
                    hintText: AppLocalizations.of(context)!.confirmNewPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.fieldRequired;
                      }
                      if (value != _newPasswordController.text) {
                        return AppLocalizations.of(context)!.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.sp),
                  CustomButton(
                    loading: loading,
                    onTap: () async {
                      if (_formResetKey.currentState?.validate() ?? false) {
                        _handleResetPassword(ref, context);
                      }
                    },
                    borderColor: GlobalColors.borderColor,
                    text: AppLocalizations.of(context)!.continueButton,
                    height: 48.h,
                    containerColor: GlobalColors.orange,
                    width: 342.w,
                    textColor: Colors.white,
                  ),
                  SizedBox(height: 16.sp),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}