import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/camera_monitoring.dart';
import '../../application/operations_controller.dart';

class CameraMonitorPage extends ConsumerStatefulWidget {
  const CameraMonitorPage({super.key});

  @override
  ConsumerState<CameraMonitorPage> createState() => _CameraMonitorPageState();
}

class _CameraMonitorPageState extends ConsumerState<CameraMonitorPage> {
  String? _selectedId;
  final _audioEnabledId = ValueNotifier<String?>(null);
  int? _gridColumns;

  @override
  void dispose() {
    _audioEnabledId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    title: 'Câmeras RTSP',
    child: ref
        .watch(appSettingsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (settings) {
            final cameras = onvifCamerasFromSettings(
              settings,
            ).where((camera) => camera.enabled).toList(growable: false);
            final selected = cameras
                .where((camera) => camera.id == _selectedId)
                .firstOrNull;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CameraToolbar(
                  cameras: cameras,
                  selected: selected,
                  gridColumns: _gridColumns,
                  onGridColumnsChanged: (columns) =>
                      setState(() => _gridColumns = columns),
                  onSelected: (camera) => setState(() {
                    _selectedId = camera.id;
                  }),
                ),
                const SizedBox(height: 10),
                if (cameras.isEmpty)
                  const _EmptyCameraState()
                else
                  _CameraGrid(
                    cameras: cameras,
                    selectedId: _selectedId,
                    audioEnabledId: _audioEnabledId,
                    configuredColumns: _gridColumns,
                    onTap: (camera) => setState(() => _selectedId = camera.id),
                    onPopup: (camera) => _openPopup(context, camera),
                  ),
              ],
            );
          },
        ),
  );

  Future<void> _openPopup(
    BuildContext context,
    OnvifCameraConfig camera,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(title: Text(camera.name)),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: _LiveCameraTile(
              camera: camera,
              audioEnabledId: _audioEnabledId,
              large: true,
              selected: true,
              onTap: () {},
              onPopup: null,
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraToolbar extends StatelessWidget {
  const _CameraToolbar({
    required this.cameras,
    required this.selected,
    required this.gridColumns,
    required this.onGridColumnsChanged,
    required this.onSelected,
  });

  final List<OnvifCameraConfig> cameras;
  final OnvifCameraConfig? selected;
  final int? gridColumns;
  final ValueChanged<int?> onGridColumnsChanged;
  final ValueChanged<OnvifCameraConfig> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _CameraMetric(
              icon: Icons.videocam_outlined,
              value: '${cameras.length}',
              label: 'ativas',
            ),
            _CameraMetric(
              icon: Icons.view_comfy_alt_outlined,
              value: gridColumns == null ? 'auto' : '${gridColumns}x',
              label: 'grade',
            ),
            _GridLayoutPicker(
              value: gridColumns,
              onChanged: onGridColumnsChanged,
            ),
            if (cameras.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 210, maxWidth: 320),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: .55,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<OnvifCameraConfig>(
                        value: selected,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(8),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        hint: Text('Selecionar canal', style: text.labelLarge),
                        items: [
                          for (final camera in cameras)
                            DropdownMenuItem(
                              value: camera,
                              child: Text(
                                camera.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (camera) {
                          if (camera != null) onSelected(camera);
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridLayoutPicker extends StatelessWidget {
  const _GridLayoutPicker({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  static const _options = <_GridLayoutOption>[
    _GridLayoutOption(null, 'Auto', Icons.auto_awesome_mosaic_outlined),
    _GridLayoutOption(1, '1', Icons.crop_square_rounded),
    _GridLayoutOption(2, '2', Icons.grid_view_rounded),
    _GridLayoutOption(3, '3', Icons.view_module_outlined),
    _GridLayoutOption(4, '4', Icons.dashboard_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in _options) ...[
                _GridLayoutButton(
                  option: option,
                  selected: option.columns == value,
                  onPressed: () => onChanged(option.columns),
                ),
                if (option != _options.last) const SizedBox(width: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GridLayoutOption {
  const _GridLayoutOption(this.columns, this.label, this.icon);

  final int? columns;
  final String label;
  final IconData icon;
}

class _GridLayoutButton extends StatelessWidget {
  const _GridLayoutButton({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final _GridLayoutOption option;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Tooltip(
      message: option.columns == null
          ? 'Grade automática'
          : '${option.columns} canal(is) por linha',
      child: Material(
        color: selected
            ? scheme.primary
            : scheme.surface.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: option.columns == null ? 68 : 52,
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: selected
                    ? scheme.primary
                    : scheme.outlineVariant.withValues(alpha: .7),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Center(
                    child: option.columns == null
                        ? Icon(
                            option.icon,
                            size: 19,
                            color: selected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          )
                        : _GridGlyph(
                            columns: option.columns!,
                            color: selected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          ),
                  ),
                ),
                Text(
                  option.label,
                  maxLines: 1,
                  style: text.labelSmall?.copyWith(
                    color: selected ? scheme.onPrimary : scheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridGlyph extends StatelessWidget {
  const _GridGlyph({required this.columns, required this.color});

  final int columns;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final rows = columns >= 3 ? 2 : 1;
    return SizedBox(
      width: 28,
      height: 18,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1.25,
        ),
        itemCount: columns * rows,
        itemBuilder: (_, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color.withValues(alpha: .82), width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _CameraMetric extends StatelessWidget {
  const _CameraMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: scheme.onPrimaryContainer),
            const SizedBox(width: 8),
            Text(
              value,
              style: text.titleSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: text.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: .78),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraGrid extends StatelessWidget {
  const _CameraGrid({
    required this.cameras,
    required this.selectedId,
    required this.audioEnabledId,
    required this.configuredColumns,
    required this.onTap,
    required this.onPopup,
  });

  final List<OnvifCameraConfig> cameras;
  final String? selectedId;
  final ValueNotifier<String?> audioEnabledId;
  final int? configuredColumns;
  final ValueChanged<OnvifCameraConfig> onTap;
  final ValueChanged<OnvifCameraConfig> onPopup;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final count = _columnCount(width);
    final gap = width < 560 ? 7.0 : 10.0;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        childAspectRatio: _aspectRatio(width, count),
      ),
      itemCount: cameras.length,
      itemBuilder: (context, index) {
        final camera = cameras[index];
        return _LiveCameraTile(
          camera: camera,
          audioEnabledId: audioEnabledId,
          selected: camera.id == selectedId,
          large: cameras.length == 1,
          onTap: () => onTap(camera),
          onPopup: () => onPopup(camera),
        );
      },
    );
  }

  int _columnCount(double width) {
    if (configuredColumns != null) {
      final maxConfigured = cameras.length < 4 ? cameras.length : 4;
      return configuredColumns!.clamp(1, maxConfigured);
    }
    final maxByWidth = width >= 1180
        ? 4
        : width >= 820
        ? 3
        : width >= 560
        ? 2
        : 1;
    return maxByWidth.clamp(1, cameras.length);
  }

  double _aspectRatio(double width, int count) {
    if (count == 1) return width < 560 ? 16 / 10 : 16 / 9;
    if (width < 560) return count == 2 ? 1.08 : .9;
    return count >= 4 ? 1.45 : 1.35;
  }
}

class _LiveCameraTile extends StatefulWidget {
  const _LiveCameraTile({
    required this.camera,
    required this.audioEnabledId,
    required this.selected,
    required this.large,
    required this.onTap,
    required this.onPopup,
  });

  final OnvifCameraConfig camera;
  final ValueNotifier<String?> audioEnabledId;
  final bool selected;
  final bool large;
  final VoidCallback onTap;
  final VoidCallback? onPopup;

  @override
  State<_LiveCameraTile> createState() => _LiveCameraTileState();
}

class _LiveCameraTileState extends State<_LiveCameraTile> {
  late final Player _player;
  late final VideoController _videoController;
  bool _opening = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    widget.audioEnabledId.addListener(_handleAudioChanged);
    unawaited(_applyAudioState());
    _openStream();
  }

  @override
  void didUpdateWidget(covariant _LiveCameraTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.camera.id != widget.camera.id ||
        oldWidget.camera.rtspUrl != widget.camera.rtspUrl) {
      _openStream();
    }
    if (oldWidget.audioEnabledId != widget.audioEnabledId) {
      oldWidget.audioEnabledId.removeListener(_handleAudioChanged);
      widget.audioEnabledId.addListener(_handleAudioChanged);
      unawaited(_applyAudioState());
    }
  }

  @override
  void dispose() {
    widget.audioEnabledId.removeListener(_handleAudioChanged);
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _openStream() async {
    setState(() => _opening = true);
    try {
      await _applyAudioState();
      await _player.open(Media(widget.camera.rtspUrl), play: true);
      await _applyAudioState();
      if (!mounted) return;
      setState(() => _opening = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _opening = false);
    }
  }

  Future<void> _applyAudioState() async {
    await _player.setVolume(_audioEnabled ? 100 : 0);
  }

  bool get _audioEnabled => widget.audioEnabledId.value == widget.camera.id;

  void _handleAudioChanged() {
    unawaited(_applyAudioState());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = widget.selected
        ? scheme.primary
        : scheme.outlineVariant.withValues(alpha: .62);
    return InkWell(
      onTap: widget.onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: widget.selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Video(controller: _videoController, fit: BoxFit.cover),
              if (_opening)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(
                      child: SizedBox(
                        width: widget.large ? 28 : 22,
                        height: widget.large ? 28 : 22,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    widget.large ? 12 : 9,
                    widget.large ? 10 : 8,
                    widget.large ? 12 : 9,
                    widget.large ? 22 : 18,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .78),
                        Colors.black.withValues(alpha: .42),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      _CameraLiveDot(opening: _opening),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.camera.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: widget.large ? 14 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: _CameraActions(
                  audioEnabled: _audioEnabled,
                  onAudio: () => widget.audioEnabledId.value = _audioEnabled
                      ? null
                      : widget.camera.id,
                  onPopup: widget.onPopup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraLiveDot extends StatelessWidget {
  const _CameraLiveDot({required this.opening});

  final bool opening;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .38),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white24),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: opening ? Colors.amberAccent : Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            opening ? '...' : 'LIVE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    ),
  );
}

class _CameraActions extends StatelessWidget {
  const _CameraActions({
    required this.audioEnabled,
    required this.onAudio,
    required this.onPopup,
  });

  final bool audioEnabled;
  final VoidCallback onAudio;
  final VoidCallback? onPopup;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .58),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white24),
    ),
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundCameraButton(
            tooltip: audioEnabled ? 'Desativar áudio' : 'Ativar áudio',
            icon: audioEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            selected: audioEnabled,
            onPressed: onAudio,
          ),
          if (onPopup != null) ...[
            const SizedBox(width: 2),
            _RoundCameraButton(
              tooltip: 'Ampliar',
              icon: Icons.open_in_full_rounded,
              selected: false,
              onPressed: onPopup!,
            ),
          ],
        ],
      ),
    ),
  );
}

class _RoundCameraButton extends StatelessWidget {
  const _RoundCameraButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? scheme.primary.withValues(alpha: .95)
            : Colors.white.withValues(alpha: .08),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
    );
  }
}

class _EmptyCameraState extends StatelessWidget {
  const _EmptyCameraState();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 42,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum canal RTSP configurado.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text('Cadastre as câmeras na aba Configurações.'),
        ],
      ),
    ),
  );
}
