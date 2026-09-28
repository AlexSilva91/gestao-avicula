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
  bool _showAll = true;

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
            final visible = _showAll ? cameras : [?selected];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CameraToolbar(
                  cameras: cameras,
                  selected: selected,
                  showAll: _showAll,
                  onShowAll: () => setState(() => _showAll = true),
                  onSelectOnly: cameras.isEmpty
                      ? null
                      : () => setState(() {
                          _selectedId ??= cameras.first.id;
                          _showAll = false;
                        }),
                  onSelected: (camera) => setState(() {
                    _selectedId = camera.id;
                    _showAll = false;
                  }),
                ),
                const SizedBox(height: 10),
                if (cameras.isEmpty)
                  const _EmptyCameraState()
                else
                  _CameraGrid(
                    cameras: visible,
                    selectedId: _selectedId,
                    onTap: (camera) => setState(() {
                      _selectedId = camera.id;
                      _showAll = false;
                    }),
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
    required this.showAll,
    required this.onShowAll,
    required this.onSelectOnly,
    required this.onSelected,
  });

  final List<OnvifCameraConfig> cameras;
  final OnvifCameraConfig? selected;
  final bool showAll;
  final VoidCallback onShowAll;
  final VoidCallback? onSelectOnly;
  final ValueChanged<OnvifCameraConfig> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      FilterChip(
        selected: showAll,
        avatar: const Icon(Icons.grid_view_rounded, size: 18),
        label: Text('Todos (${cameras.length})'),
        onSelected: (_) => onShowAll(),
      ),
      FilterChip(
        selected: !showAll,
        avatar: const Icon(Icons.select_all_outlined, size: 18),
        label: const Text('Canal isolado'),
        onSelected: onSelectOnly == null ? null : (_) => onSelectOnly!(),
      ),
      if (cameras.isNotEmpty)
        DropdownButton<OnvifCameraConfig>(
          value: selected,
          hint: const Text('Selecionar canal'),
          items: [
            for (final camera in cameras)
              DropdownMenuItem(value: camera, child: Text(camera.name)),
          ],
          onChanged: (camera) {
            if (camera != null) onSelected(camera);
          },
        ),
    ],
  );
}

class _CameraGrid extends StatelessWidget {
  const _CameraGrid({
    required this.cameras,
    required this.selectedId,
    required this.onTap,
    required this.onPopup,
  });

  final List<OnvifCameraConfig> cameras;
  final String? selectedId;
  final ValueChanged<OnvifCameraConfig> onTap;
  final ValueChanged<OnvifCameraConfig> onPopup;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final count = cameras.length <= 1
        ? 1
        : width >= 1180
        ? 4
        : width >= 820
        ? 3
        : width >= 560
        ? 2
        : 1;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: count == 1 ? 16 / 9 : 1.35,
      ),
      itemCount: cameras.length,
      itemBuilder: (context, index) {
        final camera = cameras[index];
        return _LiveCameraTile(
          camera: camera,
          selected: camera.id == selectedId,
          large: cameras.length == 1,
          onTap: () => onTap(camera),
          onPopup: () => onPopup(camera),
        );
      },
    );
  }
}

class _LiveCameraTile extends StatefulWidget {
  const _LiveCameraTile({
    required this.camera,
    required this.selected,
    required this.large,
    required this.onTap,
    required this.onPopup,
  });

  final OnvifCameraConfig camera;
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
  StreamSubscription<String>? _errorSubscription;
  bool _opening = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _errorSubscription = _player.stream.error.listen((error) {
      if (mounted) setState(() => _error = error);
    });
    _openStream();
  }

  @override
  void didUpdateWidget(covariant _LiveCameraTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.camera.id != widget.camera.id ||
        oldWidget.camera.rtspUrl != widget.camera.rtspUrl) {
      _openStream();
    }
  }

  @override
  void dispose() {
    unawaited(_errorSubscription?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _openStream() async {
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      await _player.open(Media(widget.camera.rtspUrl), play: true);
      if (!mounted) return;
      setState(() => _opening = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _opening = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: widget.onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.selected ? scheme.primary : scheme.outlineVariant,
            width: widget.selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Video(controller: _videoController, fit: BoxFit.cover),
              if (_opening)
                const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (_error != null)
                _CameraMessage(
                  icon: Icons.videocam_off_outlined,
                  text: 'Sem transmissão RTSP',
                  detail: _error!,
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  color: Colors.black.withValues(alpha: .62),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
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
                      if (widget.onPopup != null)
                        IconButton(
                          tooltip: 'Ampliar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          onPressed: widget.onPopup,
                          icon: const Icon(
                            Icons.open_in_full,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                    ],
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

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({
    required this.icon,
    required this.text,
    required this.detail,
  });

  final IconData icon;
  final String text;
  final String detail;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    ),
  );
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
