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

  @override
  void initState() {
    super.initState();
    _summary = widget.repository.getSummary();
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

  Future<void> _testStorage() async {
    final ready = await widget.repository.checkStorage();
    if (!mounted) return;
    _showMessage(
      ready
          ? 'Modo local listo. IndexedDB disponible.'
          : 'No fue posible acceder al almacenamiento local.',
      success: ready,
    );
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
            const SizedBox(height: 12),
            Text('Administración', style: AppTypography.screenTitle),
            const SizedBox(height: 4),
            Text(
              'Datos guardados en este tótem.',
              style: AppTypography.body.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _AdminMetric(
                  label: 'Registros',
                  value: loading ? '—' : '${summary?.total ?? 0}',
                  icon: Icons.people_alt_outlined,
                ),
                const SizedBox(width: 16),
                _AdminMetric(
                  label: 'Pendientes',
                  value: loading ? '—' : '${summary?.pending ?? 0}',
                  icon: Icons.cloud_upload_outlined,
                  accent: AppColors.techCyan,
                ),
                const SizedBox(width: 16),
                _AdminMetric(
                  label: 'Sincronizados',
                  value: loading ? '—' : '${summary?.synced ?? 0}',
                  icon: Icons.cloud_done_outlined,
                  accent: AppColors.successGreen,
                ),
                const SizedBox(width: 16),
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
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
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
                    child: const Icon(
                      Icons.storage_rounded,
                      color: AppColors.techCyan,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Modo local', style: AppTypography.subtitle),
                        const SizedBox(height: 3),
                        Text(
                          'Los registros permanecen en este navegador. La sincronización se conectará después.',
                          style: AppTypography.auxiliary.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GpaPrimaryButton(
                        label: 'Exportar Excel',
                        icon: Icons.download_rounded,
                        state: _exporting
                            ? GpaButtonState.loading
                            : GpaButtonState.normal,
                        onPressed: _exporting ? null : _export,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GpaSecondaryButton(
                        label: 'Probar sonido',
                        icon: Icons.volume_up_rounded,
                        onPressed: _testSound,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GpaSecondaryButton(
                        label: 'Probar conexión',
                        icon: Icons.storage_rounded,
                        onPressed: _testStorage,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GpaSecondaryButton(
                        label: 'Volver al kiosco',
                        icon: Icons.arrow_back_rounded,
                        onPressed: widget.onBack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
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
        height: 132,
        padding: const EdgeInsets.all(18),
        decoration: AppSurfaces.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 26),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.screenTitle.copyWith(fontSize: 29),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.auxiliary,
            ),
          ],
        ),
      ),
    );
  }
}
