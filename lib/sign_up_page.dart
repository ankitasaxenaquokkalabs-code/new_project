import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

const _brandColor = Color(0xFF4F008B);
const _greyPlaceholder = Color(0xFF7F7F7F);
const _greyBorder = Color(0xFFD0CECE);
const _errorColor = Color(0xFFFF375E);
const _inputBgColor = Color.fromRGBO(79, 0, 139, 0.02);

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
      _firstNameCtrl, _lastNameCtrl, _mobileCtrl,
      _altMobileCtrl, _emailCtrl, _passwordCtrl, _confirmCtrl,
    ]) {
      ctrl.addListener(_rebuild);
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final ctrl in [
      _firstNameCtrl, _lastNameCtrl, _mobileCtrl,
      _altMobileCtrl, _emailCtrl, _passwordCtrl, _confirmCtrl,
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
      _passwordCtrl.text.isNotEmpty &&
      _passwordCtrl.text == _confirmCtrl.text;

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
      _showErrors && _profileImage == null ? 'Profile photo is required' : null;
  String? get _firstNameError =>
      _showErrors && _firstNameCtrl.text.trim().isEmpty ? 'First name is required' : null;
  String? get _lastNameError =>
      _showErrors && _lastNameCtrl.text.trim().isEmpty ? 'Last name is required' : null;
  String? get _mobileError {
    if (!_showErrors) return null;
    if (_mobileCtrl.text.trim().isEmpty) return 'Mobile number is required';
    if (!_isMobileValid) return 'Enter a valid mobile number';
    return null;
  }
  String? get _emailError {
    if (!_showErrors) return null;
    if (_emailCtrl.text.trim().isEmpty) return 'Email address is required';
    if (!_isEmailValid) return 'Enter a valid email address';
    return null;
  }
  String? get _passwordError {
    if (!_showErrors) return null;
    if (_passwordCtrl.text.isEmpty) return 'Password is required';
    return null;
  }
  String? get _confirmError {
    if (!_showErrors) return null;
    if (_confirmCtrl.text.isEmpty) return 'Confirm password is required';
    if (!_passwordsMatch) return 'Passwords do not match';
    return null;
  }
  String? get _consentError =>
      _showErrors && !_consentChecked ? 'You must accept the terms' : null;

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
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
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
    Color color = _greyPlaceholder,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  TextStyle get _errorStyle =>
      _manrope(fontSize: 11, fontWeight: FontWeight.w400, color: _errorColor);

  // --- Input styling ---

  InputBorder get _fieldBorder => UnderlineInputBorder(
        borderSide: const BorderSide(color: _greyBorder, width: 1),
        borderRadius: BorderRadius.circular(5),
      );

  InputBorder get _errorBorder => UnderlineInputBorder(
        borderSide: const BorderSide(color: _errorColor, width: 1),
        borderRadius: BorderRadius.circular(5),
      );

  InputDecoration _baseDecoration(String label, {String? error}) => InputDecoration(
        labelText: label,
        labelStyle: _manrope(fontSize: 14),
        floatingLabelStyle: _manrope(fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: _inputBgColor,
        enabledBorder: error != null ? _errorBorder : _fieldBorder,
        focusedBorder: error != null ? _errorBorder : _fieldBorder,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
          height: 50,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            obscuringCharacter: '\u2022',
            textCapitalization: textCapitalization, // NEW

            style: _manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _brandColor),
            scrollPadding: const EdgeInsets.only(bottom: 25),
            decoration: _baseDecoration(label, error: error).copyWith(
              suffixIcon: suffixIcon,
              suffixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 24),
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
          obscure ? 'assets/icons/eye.svg' : 'assets/icons/eye_closed.svg',
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
    String? hintText,
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
            color: _inputBgColor,
            borderRadius: BorderRadius.circular(5),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border(

              bottom: BorderSide(color: error != null ? _errorColor : _greyBorder, width: 1,),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Image.asset('assets/images/uae_flag.png', width: 20, height: 20, fit: BoxFit.cover),
              const SizedBox(width: 3),
              if(label == 'Mobile number (optional)')
              SvgPicture.asset('assets/icons/dropdown_arrow2.svg', width: 10, height: 5),
              if(label != 'Mobile number (optional)')
              const SizedBox(width: 1),

              const SizedBox(width: 3),
              Text('971', style: _manrope(fontWeight: FontWeight.w700, color: _brandColor)),
              const SizedBox(width: 3),
              Text('I', style: _manrope(fontWeight: FontWeight.w400)),
              const SizedBox(width: 4),
              Expanded(
                child: _FloatingLabelInput(
                  controller: controller,
                  label: label,
                  floatedLabel: label.split('(ex').first.trim(), // "* Mobile number"
                  labelStyle: _manrope(fontSize: 14),
                  floatedLabelStyle: _manrope(fontSize: 10),
                  textStyle: _manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _brandColor,
                  ),
                ),
              ),
              if (isValid) ...[
                SvgPicture.asset('assets/icons/checkmark.svg', width: 18, height: 18),
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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 6),
              _buildTitleBar(),
              const SizedBox(height: 22),
              _buildProfileIcon(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              if (!keyboardOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: _buildCreateButton(),
                ),

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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: SvgPicture.asset('assets/icons/back_arrow.svg', width: 9, height: 25),
              ),
            ),
            Center(
              child: Text(
                'Create an account',
                style: _manrope(fontSize: 18, fontWeight: FontWeight.w700, color: _brandColor),
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
                      border: Border.all(color: _brandColor, width: 2),
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
                      color: const Color(0xFFE7E6E6),
                      border: Border.all(
                        color: _profileError != null ? _errorColor : _brandColor,
                        width: 2,
                      ),
                    ),
                  ),
                  Center(
                    child: SvgPicture.asset('assets/icons/camera_icon.svg', width: 50, height: 50),
                  ),
                ],
                if (hasImage)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SvgPicture.asset('assets/icons/edit_icon.svg', width: 22, height: 22),
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
            label: '* First name',
            error: _firstNameError,
            textCapitalization: TextCapitalization.words, // NEW

          ),
        ),
        const SizedBox(width: 21),
        Expanded(
          child: _simpleField(
            controller: _lastNameCtrl,
            label: '* Last name',
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
          'This mobile number will be used for you to Sign In\nand will allow us to call you upon your request',
          textAlign: TextAlign.center,
          style: _manrope(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 5),
        _phoneField(
          controller: _mobileCtrl,
          label: '* Mobile number(ex: 50*******)',
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
          'Do you have an alternative mobile number for messaging?(WhatsApp or Telegram)',
          textAlign: TextAlign.center,
          style: _manrope(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 5),
        _phoneField(
          controller: _altMobileCtrl,
          label: 'Mobile number (optional)',
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
          label: '* Email address',
          keyboardType: TextInputType.emailAddress,
          error: _emailError,
          suffixIcon: _isEmailValid
              ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: SvgPicture.asset(
                'assets/icons/checkmark.svg',
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
          label: '* Password',
          obscure: _obscurePassword,
          error: _passwordError,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 5),
        _passwordFieldWidget(
          controller: _confirmCtrl,
          label: '* Confirm password',
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

                  color: _inputBgColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),

                  border: Border(
                    bottom: BorderSide(

                      color: _consentError != null ? _errorColor : _greyBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: _consentChecked
                    ? const Icon(Icons.check, size: 18, color: _brandColor)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: _manrope(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
                  children: [
                    const TextSpan(text: 'I consent to the '),
                    TextSpan(text: 'Terms of Service', style: _manrope(fontSize: 12, fontWeight: FontWeight.w400, color: _brandColor)),
                    const TextSpan(text: ', '),
                    TextSpan(text: 'Privacy Policy', style: _manrope(fontSize: 12, fontWeight: FontWeight.w400, color: _brandColor)),
                    const TextSpan(text: ',\nand '),
                    TextSpan(text: 'Payment & Cancellation Policy', style: _manrope(fontSize: 12, fontWeight: FontWeight.w400, color: _brandColor)),
                    const TextSpan(text: ' of ABAPRO'),
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
          color: _isFormComplete ? _brandColor : _greyBorder,
          borderRadius: BorderRadius.circular(65),
        ),
        child: Center(
          child: Text(
            'Create my account',
            style: _manrope(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
  final String label;          // shown when empty & unfocused
  final String floatedLabel;   // shown above the text
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