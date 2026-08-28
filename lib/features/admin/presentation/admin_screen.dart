import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/sound_controller.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/export/gpa_excel_exporter.dart';
import '../../../data/repositories/interest_submission_repository.dart';
import '../../../shared/buttons/gpa_buttons.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    required this.repository,
    required this.exporter,
    required this.onBack,
    super.key,
  });

  final InterestSubmissionRepository repository;
  final GpaExcelExporter exporter;
  final VoidCallback onBack;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<RegistrationStorageSummary> _summary;
  bool _exporting = false;
  bool _checkingConnections = false;
  bool _clearingRecords = false;
  _StorageState _localState = _StorageState.checking;
  _StorageState _serverState = _StorageState.checking;

  @override
  void initState() {
    super.initState();
    _summary = widget.repository.getSummary();
    unawaited(_reviewStatuses(announce: false));
  }

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final records = await widget.repository.getAll();
      final fileName = await widget.exporter.download(records);
      if (!mounted) return;
      _showMessage('Excel descargado: $fileName', success: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('No se pudo generar el Excel. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _testSound() {
    final sound = SoundControllerScope.maybeOf(context);
    if (sound != null) unawaited(sound.play(SoundEffect.success));
    _showMessage('Sonido listo.', success: true);
  }

  Future<void> _reviewStatuses({bool announce = true}) async {
    if (_checkingConnections || _clearingRecords) return;
    setState(() {
      _checkingConnections = true;
      _localState = _StorageState.checking;
      _serverState = _StorageState.checking;
    });

    try {
      final results = await Future.wait([
        widget.repository.checkStorage(),
        widget.repository.checkServer(),
      ]);
      final localReady = results[0];
      final serverReady = results[1];

      if (localReady && serverReady) {
        await widget.repository.synchronize();
      }

      if (!mounted) return;
      setState(() {
        _localState = localReady
            ? _StorageState.ready
            : _StorageState.unavailable;
        _serverState = serverReady
            ? _StorageState.ready
            : _StorageState.unavailable;
        _summary = widget.repository.getSummary();
      });

      if (announce) {
        if (!localReady) {
          _showMessage('El almacenamiento de este tótem no está disponible.');
        } else if (!serverReady) {
          _showMessage(
            'Guardado local listo. El servidor no respondió; los registros seguirán pendientes.',
          );
        } else {
          _showMessage(
            'Guardado local listo y servidor conectado.',
            success: true,
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _localState = _StorageState.unavailable;
        _serverState = _StorageState.unavailable;
      });
      if (announce) {
        _showMessage('No fue posible revisar los estados. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _checkingConnections = false);
    }
  }

  Future<void> _requestRecordsReset() async {
    if (_clearingRecords) return;

    final firstConfirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ResetConfirmationDialog(
        title: '¿Estás seguro?',
        message:
            'Esto borrará todos los registros guardados en este tótem. No borrará archivos, otros sitios ni la copia del servidor.',
        confirmLabel: 'Continuar',
        cancelLabel: 'Cancelar',
      ),
    );
    if (firstConfirmation != true || !mounted) return;

    final finalConfirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ResetConfirmationDialog(
        title: '¿De verdad estás seguro?',
        message:
            'El contador local volverá a cero y esta acción no se puede deshacer en este tótem.',
        confirmLabel: 'Sí, borrar registros',
        cancelLabel: 'No, conservarlos',
        finalStep: true,
      ),
    );
    if (finalConfirmation != true || !mounted) return;

    await _clearLocalRecords();
  }

  Future<void> _clearLocalRecords() async {
    setState(() => _clearingRecords = true);
    try {
      await widget.repository.clearAll();
      if (!mounted) return;
      setState(() => _summary = widget.repository.getSummary());
      _showMessage(
        'Registros de este tótem reiniciados. La copia del servidor no se borró.',
        success: true,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('No fue posible reiniciar los registros. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _clearingRecords = false);
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success
              ? AppColors.successGreen
              : AppColors.gpaCrimson,
        ),
      );
  }

  String _lastRegistration(DateTime? value) {
    if (value == null) return 'Sin registros';
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RegistrationStorageSummary>(
      future: _summary,
      builder: (context, snapshot) {
        final summary = snapshot.data;
        final loading = snapshot.connectionState != ConnectionState.done;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('Administración', style: AppTypography.screenTitle),
            const SizedBox(height: 2),
            Text(
              'Revisa los registros y el estado de guardado del tótem.',
              style: AppTypography.body.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _AdminMetric(
                  label: 'Registros',
                  value: loading ? '—' : '${summary?.total ?? 0}',
                  icon: Icons.people_alt_outlined,
                ),
                const SizedBox(width: 12),
                _AdminMetric(
                  label: 'Pendientes',
                  value: loading ? '—' : '${summary?.pending ?? 0}',
                  icon: Icons.cloud_upload_outlined,
                  accent: AppColors.techCyan,
                ),
                const SizedBox(width: 12),
                _AdminMetric(
                  label: 'Sincronizados',
                  value: loading ? '—' : '${summary?.synced ?? 0}',
                  icon: Icons.cloud_done_outlined,
                  accent: AppColors.successGreen,
                ),
                const SizedBox(width: 12),
                _AdminMetric(
                  label: 'Último registro',
                  value: loading
                      ? '—'
                      : _lastRegistration(summary?.lastRegistrationAt),
                  icon: Icons.schedule_rounded,
                  accent: AppColors.graphite,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _StorageStatusCard(
              localState: _localState,
              serverState: _serverState,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: GpaPrimaryButton(
                    label: 'Exportar Excel',
                    icon: Icons.download_rounded,
                    height: 60,
                    state: _exporting
                        ? GpaButtonState.loading
                        : GpaButtonState.normal,
                    onPressed: _exporting ? null : _export,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GpaSecondaryButton(
                    label: 'Probar sonido',
                    icon: Icons.volume_up_rounded,
                    height: 60,
                    onPressed: _testSound,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GpaSecondaryButton(
                    label: _checkingConnections
                        ? 'Revisando estados'
                        : 'Revisar estados',
                    icon: Icons.sync_rounded,
                    height: 60,
                    state: _checkingConnections
                        ? GpaButtonState.loading
                        : GpaButtonState.normal,
                    onPressed: _checkingConnections
                        ? null
                        : () => _reviewStatuses(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GpaSecondaryButton(
                    label: 'Volver al kiosco',
                    icon: Icons.arrow_back_rounded,
                    height: 60,
                    onPressed: widget.onBack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GpaDangerButton(
              label: _clearingRecords
                  ? 'Reiniciando registros'
                  : 'Reiniciar registros de prueba',
              icon: Icons.delete_forever_rounded,
              height: 60,
              expand: true,
              state: _clearingRecords
                  ? GpaButtonState.loading
                  : GpaButtonState.normal,
              onPressed: _clearingRecords ? null : _requestRecordsReset,
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Solo borra los registros de este navegador; no toca cPanel ni otros sitios.',
                textAlign: TextAlign.center,
                style: AppTypography.auxiliary.copyWith(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _StorageState { checking, ready, unavailable }

class _StorageStatusCard extends StatelessWidget {
  const _StorageStatusCard({
    required this.localState,
    required this.serverState,
  });

  final _StorageState localState;
  final _StorageState serverState;

  String get _description {
    if (localState == _StorageState.checking ||
        serverState == _StorageState.checking) {
      return 'Revisando dónde están guardándose los registros.';
    }
    if (localState == _StorageState.unavailable) {
      return 'El almacenamiento local no está disponible. No realices registros hasta revisarlo.';
    }
    if (serverState == _StorageState.unavailable) {
      return 'Puedes seguir usando el tótem. Los pendientes se enviarán al recuperar conexión.';
    }
    return 'Cada registro se guarda primero aquí y después queda respaldado en el servidor.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: AppSurfaces.card(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.techCyan.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storage_rounded, color: AppColors.techCyan),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de guardado',
                  style: AppTypography.subtitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(
                  _description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.auxiliary.copyWith(
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StorageStatusPill(label: 'En este tótem', state: localState),
          const SizedBox(width: 8),
          _StorageStatusPill(label: 'Servidor', state: serverState),
        ],
      ),
    );
  }
}

class _StorageStatusPill extends StatelessWidget {
  const _StorageStatusPill({required this.label, required this.state});

  final String label;
  final _StorageState state;

  @override
  Widget build(BuildContext context) {
    final (status, color, icon) = switch (state) {
      _StorageState.checking => (
        'Revisando',
        AppColors.graphite,
        Icons.sync_rounded,
      ),
      _StorageState.ready => (
        label == 'Servidor' ? 'Conectado' : 'Listo',
        AppColors.successGreen,
        Icons.check_circle_rounded,
      ),
      _StorageState.unavailable => (
        'Sin conexión',
        AppColors.gpaCrimson,
        Icons.error_outline_rounded,
      ),
    };

    return Container(
      width: 126,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.auxiliary.copyWith(
                    color: AppColors.carbon,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.auxiliary.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetConfirmationDialog extends StatelessWidget {
  const _ResetConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.finalStep = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool finalStep;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 190),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: AppSurfaces.card(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.gpaCrimson.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: AppColors.gpaCrimson,
                size: 31,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.screenTitle.copyWith(fontSize: 27),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: GpaSecondaryButton(
                    label: cancelLabel,
                    height: 58,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: finalStep
                      ? GpaDangerButton(
                          label: confirmLabel,
                          height: 58,
                          onPressed: () => Navigator.of(context).pop(true),
                        )
                      : GpaPrimaryButton(
                          label: confirmLabel,
                          height: 58,
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMetric extends StatelessWidget {
  const _AdminMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.accent = AppColors.gpaCrimson,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(15),
        decoration: AppSurfaces.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 24),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.screenTitle.copyWith(fontSize: 26),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.auxiliary.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
