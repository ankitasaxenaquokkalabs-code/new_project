import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _consentChecked = false;
  bool _showErrors = false;
  File? _profileImage;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _altMobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final ctrl in [
      _firstNameCtrl,
      _lastNameCtrl,
      _mobileCtrl,
      _altMobileCtrl,
      _emailCtrl,
      _passwordCtrl,
      _confirmCtrl,
    ]) {
      ctrl.addListener(_rebuild);
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final ctrl in [
      _firstNameCtrl,
      _lastNameCtrl,
      _mobileCtrl,
      _altMobileCtrl,
      _emailCtrl,
      _passwordCtrl,
      _confirmCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // --- Validation ---

  bool get _isEmailValid {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return false;
    return RegExp(r'^[\w\.\-\+]+@[\w\.\-]+\.\w{2,}$').hasMatch(email);
  }

  bool get _isMobileValid => _mobileCtrl.text.trim().length >= 7;

  bool get _isAltMobileValid => _altMobileCtrl.text.trim().length >= 7;

  bool get _passwordsMatch =>
      _passwordCtrl.text.isNotEmpty && _passwordCtrl.text == _confirmCtrl.text;

  bool get _isFormComplete =>
      _profileImage != null &&
      _firstNameCtrl.text.trim().isNotEmpty &&
      _lastNameCtrl.text.trim().isNotEmpty &&
      _isMobileValid &&
      _isEmailValid &&
      _passwordCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty &&
      _passwordsMatch &&
      _consentChecked;

  String? get _profileError =>
      _showErrors && _profileImage == null
      ? AppStrings.profilePhotoRequired
      : null;

  String? get _firstNameError =>
      _showErrors && _firstNameCtrl.text.trim().isEmpty
      ? AppStrings.firstNameRequired
      : null;

  String? get _lastNameError => _showErrors && _lastNameCtrl.text.trim().isEmpty
      ? AppStrings.lastNameRequired
      : null;

  String? get _mobileError {
    if (!_showErrors) return null;
    if (_mobileCtrl.text.trim().isEmpty) return AppStrings.mobileNumberRequired;
    if (!_isMobileValid) return AppStrings.invalidMobileNumber;
    return null;
  }

  String? get _emailError {
    if (!_showErrors) return null;
    if (_emailCtrl.text.trim().isEmpty) return AppStrings.emailRequired;
    if (!_isEmailValid) return AppStrings.invalidEmail;
    return null;
  }

  String? get _passwordError {
    if (!_showErrors) return null;
    if (_passwordCtrl.text.isEmpty) return AppStrings.passwordRequired;
    return null;
  }

  String? get _confirmError {
    if (!_showErrors) return null;
    if (_confirmCtrl.text.isEmpty) return AppStrings.confirmPasswordRequired;
    if (!_passwordsMatch) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  String? get _consentError =>
      _showErrors && !_consentChecked ? AppStrings.termsRequired : null;

  void _onCreateTap() {
    if (_isFormComplete) {
      // Form is valid — handle submission
      return;
    }
    setState(() => _showErrors = true);
  }

  // --- Image Picker ---

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(AppStrings.camera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.gallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, maxWidth: 512);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  // --- Text Styles ---

  TextStyle _manrope({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.placeholder,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  TextStyle get _errorStyle =>
      _manrope(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.error);

  // --- Input styling ---

  InputBorder get _fieldBorder => UnderlineInputBorder(
    borderSide: const BorderSide(color: AppColors.border, width: 1),
    borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
  );

  InputBorder get _errorBorder => UnderlineInputBorder(
    borderSide: const BorderSide(color: AppColors.error, width: 1),
    borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
  );

  InputDecoration _baseDecoration(String label, {String? error}) =>
      InputDecoration(
        labelText: label,
        labelStyle: _manrope(fontSize: 14),
        floatingLabelStyle: _manrope(fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: AppColors.inputBackground,
        enabledBorder: error != null ? _errorBorder : _fieldBorder,
        focusedBorder: error != null ? _errorBorder : _fieldBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
      );

  Widget _errorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(error, style: _errorStyle),
    );
  }

  // --- Reusable Field Builders ---

  Widget _simpleField({
    required TextEditingController controller,
    required String label,
    String? error,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none, // NEW

    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppDimensions.fieldHeight,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            obscuringCharacter: '\u2022',
            textCapitalization: textCapitalization,
            // NEW

            style: _manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.brand,
            ),
            scrollPadding: const EdgeInsets.only(bottom: 25),
            decoration: _baseDecoration(label, error: error).copyWith(
              suffixIcon: suffixIcon,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 24,
              ),
            ),
          ),
        ),
        _errorText(error),
      ],
    );
  }

  Widget _eyeIcon({required bool obscure, required VoidCallback onToggle}) {
    // Open eye (visibility) when password is obscured (dots) → tap to reveal
    // Closed eye (visibility_off) when password is revealed → tap to hide
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.only(right: 7),
        child: SvgPicture.asset(
          obscure ? AppAssets.eye : AppAssets.eyeClosed,
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  Widget _passwordFieldWidget({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? error,
  }) {
    return _simpleField(
      controller: controller,
      label: label,
      obscureText: obscure,
      error: error,
      suffixIcon: _eyeIcon(obscure: obscure, onToggle: onToggle),
    );
  }

  Widget _phoneField({
    required TextEditingController controller,
    required String label,
    required bool isValid,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
            border: Border(
              bottom: BorderSide(
                color: error != null ? AppColors.error : AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Image.asset(
                AppAssets.uaeFlag,
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 3),
              if (label == AppStrings.optionalMobileNumber)
                SvgPicture.asset(
                  AppAssets.dropdownArrow,
                  width: 10,
                  height: 5,
                ),
              if (label != AppStrings.optionalMobileNumber)
                const SizedBox(width: 1),

              const SizedBox(width: 3),
              Text(
                '971',
                style: _manrope(
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(width: 3),
              Text('I', style: _manrope(fontWeight: FontWeight.w400)),
              const SizedBox(width: 4),
              Expanded(
                child: _FloatingLabelInput(
                  controller: controller,
                  label: label,
                  floatedLabel: label.split('(ex').first.trim(),
                  // "* Mobile number"
                  labelStyle: _manrope(fontSize: 14),
                  floatedLabelStyle: _manrope(fontSize: 10),
                  textStyle: _manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
              ),
              if (isValid) ...[
                SvgPicture.asset(
                  AppAssets.checkmark,
                  width: 18,
                  height: 18,
                ),
              ],
              const SizedBox(width: 10),
            ],
          ),
        ),
        _errorText(error),
      ],
    );
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 6),
              _buildTitleBar(),
              const SizedBox(height: 22),
              _buildProfileIcon(),

              // Scrollable content area
              Expanded(
                child: ClipRect(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pageHorizontalPadding,
                          ),
                          child: Column(
                            children: [
                              _buildNameRow(),
                              const SizedBox(height: 15),
                              _buildMobileSection(),
                              const SizedBox(height: 15),
                              _buildWhatsAppSection(),
                              const SizedBox(height: 15),
                              _buildEmailPasswordSection(),
                              const SizedBox(height: 15),
                              _buildConsent(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed bottom button — outside the scroll view
              if (!keyboardOpen) ...[
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _buildCreateButton(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return SizedBox(
      height: 25,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontalPadding,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: SvgPicture.asset(
                  AppAssets.backArrow,
                  width: 9,
                  height: 25,
                ),
              ),
            ),
            Center(
              child: Text(
                AppStrings.createAccount,
                style: _manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon() {
    final hasImage = _profileImage != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (hasImage)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.brand, width: 2),
                      image: DecorationImage(
                        image: FileImage(_profileImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else ...[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.profilePlaceholder,
                      border: Border.all(
                        color: _profileError != null
                            ? AppColors.error
                            : AppColors.brand,
                        width: 2,
                      ),
                    ),
                  ),
                  Center(
                    child: SvgPicture.asset(
                      AppAssets.camera,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
                if (hasImage)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SvgPicture.asset(
                      AppAssets.edit,
                      width: 22,
                      height: 22,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_profileError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_profileError!, style: _errorStyle),
          ),
      ],
    );
  }

  Widget _buildNameRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _simpleField(
            controller: _firstNameCtrl,
            label: AppStrings.firstName,
            error: _firstNameError,
            textCapitalization: TextCapitalization.words, // NEW
          ),
        ),
        const SizedBox(width: 21),
        Expanded(
          child: _simpleField(
            controller: _lastNameCtrl,
            label: AppStrings.lastName,
            error: _lastNameError,
            textCapitalization: TextCapitalization.words, // NEW
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSection() {
    return Column(
      children: [
        Text(
          AppStrings.mobileSignInHint,
          textAlign: TextAlign.center,
          style: _manrope(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 5),
        _phoneField(
          controller: _mobileCtrl,
          label: AppStrings.mobileNumber,
          isValid: _isMobileValid,
          error: _mobileError,
        ),
      ],
    );
  }

  Widget _buildWhatsAppSection() {
    return Column(
      children: [
        Text(
          AppStrings.alternativeMobileHint,
          textAlign: TextAlign.center,
          style: _manrope(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 5),
        _phoneField(
          controller: _altMobileCtrl,
          label: AppStrings.optionalMobileNumber,
          isValid: _isAltMobileValid,
        ),
      ],
    );
  }

  Widget _buildEmailPasswordSection() {
    return Column(
      children: [
        _simpleField(
          controller: _emailCtrl,
          label: AppStrings.emailAddress,
          keyboardType: TextInputType.emailAddress,
          error: _emailError,
          suffixIcon: _isEmailValid
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: SvgPicture.asset(
                      AppAssets.checkmark,
                      width: 18,
                      height: 18,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 15),
        _passwordFieldWidget(
          controller: _passwordCtrl,
          label: AppStrings.password,
          obscure: _obscurePassword,
          error: _passwordError,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 5),
        _passwordFieldWidget(
          controller: _confirmCtrl,
          label: AppStrings.confirmPassword,
          obscure: _obscureConfirm,
          error: _confirmError,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ],
    );
  }

  Widget _buildConsent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _consentChecked = !_consentChecked),
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),

                  border: Border(
                    bottom: BorderSide(
                        color: _consentError != null
                          ? AppColors.error
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: _consentChecked
                    ? const Icon(Icons.check, size: 18, color: AppColors.brand)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: _manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(text: AppStrings.consentPrefix),
                    TextSpan(
                      text: AppStrings.termsOfService,
                      style: _manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.brand,
                      ),
                    ),
                    const TextSpan(text: ', '),
                    TextSpan(
                      text: AppStrings.privacyPolicy,
                      style: _manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.brand,
                      ),
                    ),
                    const TextSpan(text: ',\nand '),
                    TextSpan(
                      text: AppStrings.paymentCancellationPolicy,
                      style: _manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.brand,
                      ),
                    ),
                    const TextSpan(text: AppStrings.consentSuffix),
                  ],
                ),
              ),
            ),
          ],
        ),
        _errorText(_consentError),
      ],
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _onCreateTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isFormComplete ? AppColors.brand : AppColors.border,
          borderRadius: BorderRadius.circular(
            AppDimensions.actionButtonRadius,
          ),
        ),
        child: Center(
          child: Text(
                AppStrings.createMyAccount,
            style: _manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingLabelInput extends StatefulWidget {
  const _FloatingLabelInput({
    required this.controller,
    required this.label,
    required this.floatedLabel,
    required this.labelStyle,
    required this.floatedLabelStyle,
    required this.textStyle,
  });

  final TextEditingController controller;
  final String label; // shown when empty & unfocused
  final String floatedLabel; // shown above the text
  final TextStyle labelStyle;
  final TextStyle floatedLabelStyle;
  final TextStyle textStyle;

  @override
  State<_FloatingLabelInput> createState() => _FloatingLabelInputState();
}

class _FloatingLabelInputState extends State<_FloatingLabelInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floated = _focus.hasFocus || widget.controller.text.isNotEmpty;

    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            left: 0,
            right: 0,
            top: floated ? 6 : 16,
            child: IgnorePointer(
              child: Text(
                floated ? widget.floatedLabel : widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (floated ? widget.floatedLabelStyle : widget.labelStyle)
                    .copyWith(height: 1.2),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 13,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: TextInputType.phone,
              style: widget.textStyle.copyWith(height: 1.2),
              scrollPadding: const EdgeInsets.only(bottom: 25),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
