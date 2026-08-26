import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/animations/app_motion.dart';
import '../../../data/models/visitor_registration.dart';
import '../../../shared/keyboard/gpa_virtual_keyboard.dart';
import 'widgets/contact_panel.dart';
import 'widgets/identity_panel.dart';

enum _RegistrationPanel { identity, contact }

enum _RegistrationField { name, organization, email, phone }

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    required this.onBack,
    required this.onContinue,
    super.key,
  });

  final VoidCallback onBack;
  final Future<void> Function(VisitorRegistration registration) onContinue;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _organizationFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  final Set<_RegistrationField> _interactedFields = {};

  _RegistrationPanel _panel = _RegistrationPanel.identity;
  _RegistrationField? _activeField;
  VisitorProfile? _profile;
  bool _acceptsInformation = false;
  bool _openingNextScreen = false;

  bool get _keyboardVisible => _activeField != null;

  GpaKeyboardLayout get _keyboardLayout {
    return switch (_activeField) {
      _RegistrationField.email => GpaKeyboardLayout.email,
      _RegistrationField.phone => GpaKeyboardLayout.numeric,
      _ => GpaKeyboardLayout.text,
    };
  }

  TextEditingController? get _activeController {
    return switch (_activeField) {
      _RegistrationField.name => _nameController,
      _RegistrationField.organization => _organizationController,
      _RegistrationField.email => _emailController,
      _RegistrationField.phone => _phoneController,
      null => null,
    };
  }

  bool get _nameValid => _nameController.text.trim().isNotEmpty;

  bool get _organizationValid {
    final profile = _profile;
    if (profile == null) return false;
    return !profile.requiresOrganization ||
        _organizationController.text.trim().isNotEmpty;
  }

  bool get _emailValid {
    final email = _emailController.text.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  bool get _phoneValid {
    return _phoneController.text.replaceAll(RegExp(r'\D'), '').length >= 10;
  }

  bool get _identityValid {
    return _profile != null && _nameValid && _organizationValid;
  }

  bool get _contactValid => _emailValid && _phoneValid && _acceptsInformation;

  String? get _nameError {
    if (_activeField == _RegistrationField.name ||
        !_interactedFields.contains(_RegistrationField.name) ||
        _nameValid) {
      return null;
    }
    return 'Escribe tu nombre para continuar.';
  }

  String? get _organizationError {
    if (_activeField == _RegistrationField.organization ||
        !_interactedFields.contains(_RegistrationField.organization) ||
        _organizationValid) {
      return null;
    }
    return 'Escribe la empresa o institución para continuar.';
  }

  String? get _emailError {
    if (_activeField == _RegistrationField.email ||
        !_interactedFields.contains(_RegistrationField.email) ||
        _emailValid) {
      return null;
    }
    if (_emailController.text.isEmpty) {
      return 'Escribe tu correo para continuar.';
    }
    return 'Revisa el correo antes de continuar.';
  }

  String? get _phoneError {
    if (_activeField == _RegistrationField.phone ||
        !_interactedFields.contains(_RegistrationField.phone) ||
        _phoneValid) {
      return null;
    }
    if (_phoneController.text.isEmpty) {
      return 'Escribe tu teléfono para continuar.';
    }
    return 'Revisa el teléfono antes de continuar.';
  }

  void _selectProfile(VisitorProfile profile) {
    if (_profile == profile) return;
    if (_activeField == _RegistrationField.organization) {
      _dismissKeyboard();
    }
    setState(() {
      _profile = profile;
      _interactedFields.remove(_RegistrationField.organization);
      if (profile.organizationLabel == null) {
        _organizationController.clear();
      }
    });
  }

  void _showKeyboard(_RegistrationField field) {
    if (_activeField == field) return;
    setState(() {
      if (_activeField != null) {
        _interactedFields.add(_activeField!);
      }
      _activeField = field;
    });
  }

  void _dismissKeyboard() {
    final field = _activeField;
    if (field == null) return;
    setState(() {
      _interactedFields.add(field);
      _activeField = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _write(String value) {
    final field = _activeField;
    final controller = _activeController;
    if (field == null || controller == null) return;

    var nextValue = value;
    if (field == _RegistrationField.phone) {
      nextValue = value.replaceAll(RegExp(r'\D'), '');
    } else if ((field == _RegistrationField.name ||
            field == _RegistrationField.organization) &&
        value.length == 1 &&
        (controller.text.isEmpty || controller.text.endsWith(' '))) {
      nextValue = value.toUpperCase();
    } else if (field == _RegistrationField.email && value.startsWith('@')) {
      final atIndex = controller.text.indexOf('@');
      if (atIndex >= 0) {
        controller.text = controller.text.substring(0, atIndex);
      }
    }

    final maxLength = switch (field) {
      _RegistrationField.name => 60,
      _RegistrationField.organization || _RegistrationField.email => 80,
      _RegistrationField.phone => 15,
    };
    if (controller.text.length + nextValue.length > maxLength) return;

    setState(() {
      controller.text += nextValue;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    });
  }

  void _backspace() {
    final field = _activeField;
    final controller = _activeController;
    if (field == null || controller == null || controller.text.isEmpty) return;

    setState(() {
      controller.text = controller.text.substring(
        0,
        controller.text.length - 1,
      );
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    });
  }

  void _goToContact() {
    if (!_identityValid) return;
    _dismissKeyboard();
    setState(() => _panel = _RegistrationPanel.contact);
  }

  void _returnToIdentity() {
    _dismissKeyboard();
    setState(() => _panel = _RegistrationPanel.identity);
  }

  void _finishRegistration() {
    if (!_contactValid || _openingNextScreen) return;
    final keyboardWasVisible = _keyboardVisible;
    _dismissKeyboard();
    setState(() => _openingNextScreen = true);
    unawaited(_openInterests(keyboardWasVisible));
  }

  Future<void> _openInterests(bool keyboardWasVisible) async {
    final delay =
        (keyboardWasVisible ? AppMotion.keyboardHide : Duration.zero) +
        AppMotion.keyboardToScreen;
    await Future<void>.delayed(delay);
    if (!mounted) return;

    await widget.onContinue(
      VisitorRegistration(
        profile: _profile!,
        name: _nameController.text.trim(),
        organization: _organizationController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        acceptsInformation: _acceptsInformation,
      ),
    );
    if (mounted) setState(() => _openingNextScreen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.standard,
            switchInCurve: AppMotion.standardCurve,
            switchOutCurve: AppMotion.standardCurve,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.025, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _panel == _RegistrationPanel.identity
                ? _buildIdentityPanel()
                : _buildContactPanel(),
          ),
        ),
        GpaVirtualKeyboard(
          visible: _keyboardVisible,
          layout: _keyboardLayout,
          onText: _write,
          onBackspace: _backspace,
          onDone: _dismissKeyboard,
        ),
      ],
    );
  }

  Widget _buildIdentityPanel() {
    return IdentityPanel(
      profile: _profile,
      nameController: _nameController,
      nameFocus: _nameFocus,
      nameError: _nameError,
      nameValid: _nameValid,
      organizationController: _organizationController,
      organizationFocus: _organizationFocus,
      organizationError: _organizationError,
      identityValid: _identityValid,
      onSelectProfile: _selectProfile,
      onNameTap: () => _showKeyboard(_RegistrationField.name),
      onOrganizationTap: () => _showKeyboard(_RegistrationField.organization),
      onBack: widget.onBack,
      onContinue: _goToContact,
    );
  }

  Widget _buildContactPanel() {
    return ContactPanel(
      emailController: _emailController,
      emailFocus: _emailFocus,
      emailError: _emailError,
      emailValid: _emailValid,
      phoneController: _phoneController,
      phoneFocus: _phoneFocus,
      phoneError: _phoneError,
      phoneValid: _phoneValid,
      acceptsInformation: _acceptsInformation,
      openingNextScreen: _openingNextScreen,
      contactValid: _contactValid,
      onEmailTap: () => _showKeyboard(_RegistrationField.email),
      onPhoneTap: () => _showKeyboard(_RegistrationField.phone),
      onConsentChanged: (value) {
        setState(() => _acceptsInformation = value);
      },
      onBack: _returnToIdentity,
      onContinue: _finishRegistration,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _organizationFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }
}
