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
  final Set<String> _closedCameraIds = <String>{};
  bool _controlsExpanded = false;
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
            final cameraIds = cameras.map((camera) => camera.id).toSet();
            _closedCameraIds.removeWhere((id) => !cameraIds.contains(id));
            final openCameraIds = cameraIds
                .where((id) => !_closedCameraIds.contains(id))
                .toSet();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CameraToolbar(
                  cameras: cameras,
                  openCameraIds: openCameraIds,
                  expanded: _controlsExpanded,
                  onExpandedChanged: () =>
                      setState(() => _controlsExpanded = !_controlsExpanded),
                  gridColumns: _gridColumns,
                  onGridColumnsChanged: (columns) =>
                      setState(() => _gridColumns = columns),
                ),
                const SizedBox(height: 10),
                if (cameras.isEmpty)
                  const _EmptyCameraState()
                else
                  _CameraGrid(
                    cameras: cameras,
                    openCameraIds: openCameraIds,
                    selectedId: _selectedId,
                    audioEnabledId: _audioEnabledId,
                    configuredColumns: _gridColumns,
                    onTap: (camera) => setState(() => _selectedId = camera.id),
                    onToggleCamera: _toggleCamera,
                    onPopup: (camera) => _openPopup(context, camera),
                  ),
              ],
            );
          },
        ),
  );

  void _toggleCamera(OnvifCameraConfig camera, bool open) {
    setState(() {
      if (open) {
        _closedCameraIds.remove(camera.id);
        _selectedId = camera.id;
      } else {
        _closedCameraIds.add(camera.id);
        if (_selectedId == camera.id) _selectedId = null;
        if (_audioEnabledId.value == camera.id) _audioEnabledId.value = null;
      }
    });
  }

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
              visible: !_closedCameraIds.contains(camera.id),
              large: true,
              selected: true,
              onTap: () {},
              onVisibility: () =>
                  _toggleCamera(camera, _closedCameraIds.contains(camera.id)),
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
    required this.openCameraIds,
    required this.expanded,
    required this.onExpandedChanged,
    required this.gridColumns,
    required this.onGridColumnsChanged,
  });

  final List<OnvifCameraConfig> cameras;
  final Set<String> openCameraIds;
  final bool expanded;
  final VoidCallback onExpandedChanged;
  final int? gridColumns;
  final ValueChanged<int?> onGridColumnsChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final header = _CameraControlHeader(
              cameras: cameras,
              openCameraIds: openCameraIds,
              expanded: expanded,
              onExpandedChanged: onExpandedChanged,
            );
            final layout = _GridLayoutPicker(
              value: gridColumns,
              onChanged: onGridColumnsChanged,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: compact
                        ? layout
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(width: 304, child: layout),
                          ),
                  ),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 180),
                  sizeCurve: Curves.easeOutCubic,
                ),
                if (cameras.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Nenhum canal ativo cadastrado.',
                      style: text.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CameraControlHeader extends StatelessWidget {
  const _CameraControlHeader({
    required this.cameras,
    required this.openCameraIds,
    required this.expanded,
    required this.onExpandedChanged,
  });

  final List<OnvifCameraConfig> cameras;
  final Set<String> openCameraIds;
  final bool expanded;
  final VoidCallback onExpandedChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onExpandedChanged,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.video_camera_back_rounded,
                    color: scheme.onPrimary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoramento ao vivo',
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${openCameraIds.length} de ${cameras.length} canal(is) na tela',
                      style: text.labelSmall?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CameraMetric(
                icon: Icons.visibility_outlined,
                value: '${openCameraIds.length}',
                label: 'abertos',
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                tooltip: expanded ? 'Recolher controles' : 'Expandir controles',
                onPressed: onExpandedChanged,
                icon: AnimatedRotation(
                  turns: expanded ? .5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                constraints: const BoxConstraints.tightFor(
                  width: 34,
                  height: 34,
                ),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
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
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard_customize_outlined,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Layout da grade',
                  style: text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
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
                    if (option != _options.last) const SizedBox(width: 5),
                  ],
                ],
              ),
            ),
          ],
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
            width: option.columns == null ? 62 : 46,
            height: 48,
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
    required this.openCameraIds,
    required this.selectedId,
    required this.audioEnabledId,
    required this.configuredColumns,
    required this.onTap,
    required this.onToggleCamera,
    required this.onPopup,
  });

  final List<OnvifCameraConfig> cameras;
  final Set<String> openCameraIds;
  final String? selectedId;
  final ValueNotifier<String?> audioEnabledId;
  final int? configuredColumns;
  final ValueChanged<OnvifCameraConfig> onTap;
  final void Function(OnvifCameraConfig camera, bool open) onToggleCamera;
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
          visible: openCameraIds.contains(camera.id),
          selected: camera.id == selectedId,
          large: cameras.length == 1,
          onTap: () => onTap(camera),
          onVisibility: () =>
              onToggleCamera(camera, !openCameraIds.contains(camera.id)),
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
    required this.visible,
    required this.selected,
    required this.large,
    required this.onTap,
    required this.onVisibility,
    required this.onPopup,
  });

  final OnvifCameraConfig camera;
  final ValueNotifier<String?> audioEnabledId;
  final bool visible;
  final bool selected;
  final bool large;
  final VoidCallback onTap;
  final VoidCallback onVisibility;
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
    if (widget.visible) _openStream();
  }

  @override
  void didUpdateWidget(covariant _LiveCameraTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.camera.id != widget.camera.id ||
        oldWidget.camera.rtspUrl != widget.camera.rtspUrl) {
      if (widget.visible) _openStream();
    }
    if (!oldWidget.visible && widget.visible) {
      _openStream();
    } else if (oldWidget.visible && !widget.visible) {
      unawaited(_stopStream());
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

  Future<void> _stopStream() async {
    await _player.stop();
    if (!mounted) return;
    setState(() => _opening = false);
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
              if (widget.visible)
                Video(controller: _videoController, fit: BoxFit.cover)
              else
                const _ClosedCameraBackdrop(),
              if (widget.visible && _opening)
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
                  videoVisible: widget.visible,
                  onAudio: () => widget.audioEnabledId.value = _audioEnabled
                      ? null
                      : widget.camera.id,
                  onVisibility: widget.onVisibility,
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

class _ClosedCameraBackdrop extends StatelessWidget {
  const _ClosedCameraBackdrop();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.black, Colors.grey.shade900, Colors.black],
      ),
    ),
    child: Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Icon(
            Icons.visibility_off_rounded,
            color: Colors.white70,
            size: 28,
          ),
        ),
      ),
    ),
  );
}

class _CameraActions extends StatelessWidget {
  const _CameraActions({
    required this.audioEnabled,
    required this.videoVisible,
    required this.onAudio,
    required this.onVisibility,
    required this.onPopup,
  });

  final bool audioEnabled;
  final bool videoVisible;
  final VoidCallback onAudio;
  final VoidCallback onVisibility;
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
            tooltip: videoVisible ? 'Fechar imagem' : 'Abrir imagem',
            icon: videoVisible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            selected: videoVisible,
            onPressed: onVisibility,
          ),
          const SizedBox(width: 2),
          _RoundCameraButton(
            tooltip: audioEnabled ? 'Desativar áudio' : 'Ativar áudio',
            icon: audioEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            selected: audioEnabled,
            onPressed: videoVisible ? onAudio : () {},
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
