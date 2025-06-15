import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../models/project_model.dart';
import '../../utils/app_colors.dart';

class MediaScreen extends StatefulWidget {
  final ProjectModel project;
  final int initialTab;

  const MediaScreen({super.key, required this.project, this.initialTab = 0});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  List<String> _images = [];
  List<String> _videos = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _images = List.from(widget.project.images);
    _videos = List.from(widget.project.videos);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _getProjectMediaDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final projectDir = Directory('${appDir.path}/projects/${widget.project.id}/media');
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }
    return projectDir.path;
  }

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        try {
          // Create project media directory
          final projectDir = await _getProjectMediaDirectory();

          // Generate unique filename
          final fileName = 'image_${_uuid.v4()}.jpg';
          final targetPath = '$projectDir/$fileName';

          // Copy the image to project directory
          final File sourceFile = File(image.path);
          final File targetFile = File(targetPath);
          await sourceFile.copy(targetFile.path);

          setState(() {
            _images.add(targetPath);
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image added successfully!')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save image: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _pickVideo() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        try {
          // Create project media directory
          final projectDir = await _getProjectMediaDirectory();

          // Generate unique filename
          final fileName = 'video_${_uuid.v4()}.mp4';
          final targetPath = '$projectDir/$fileName';

          // Copy the video to project directory
          final File sourceFile = File(video.path);
          final File targetFile = File(targetPath);
          await sourceFile.copy(targetFile.path);

          setState(() {
            _videos.add(targetPath);
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video added successfully!')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save video: ${e.toString()}')));
        }
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // If permission is permanently denied, show dialog to open settings
      if (status.isPermanentlyDenied) {
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Storage Permission Required'),
                content: const Text('Please grant storage permission in settings to download media.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Open Settings')),
                ],
              ),
        );

        if (shouldOpenSettings ?? false) {
          await openAppSettings();
        }
      }
      return false;
    }
    return true; // iOS doesn't need explicit storage permission
  }

  Future<void> _downloadImage(String imagePath) async {
    try {
      if (!await _requestStoragePermission()) {
        return;
      }

      final file = File(imagePath);
      if (await file.exists()) {
        // Get the Pictures directory
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        // Create a unique filename
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newFile = File('${directory.path}/$fileName');

        // Copy the file
        await file.copy(newFile.path);

        // For Android, we need to trigger media scanner
        if (Platform.isAndroid) {
          final intent = AndroidIntent(
            action: 'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
            data: 'file://${newFile.path}',
          );
          await intent.launch();
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download image: ${e.toString()}')));
    }
  }

  Future<void> _downloadVideo(String videoPath) async {
    try {
      if (!await _requestStoragePermission()) {
        return;
      }

      final file = File(videoPath);
      if (await file.exists()) {
        // Get the Movies directory
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        // Create a unique filename
        final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final newFile = File('${directory.path}/$fileName');

        // Copy the file
        await file.copy(newFile.path);

        // For Android, we need to trigger media scanner
        if (Platform.isAndroid) {
          final intent = AndroidIntent(
            action: 'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
            data: 'file://${newFile.path}',
          );
          await intent.launch();
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video saved to gallery')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download video: ${e.toString()}')));
    }
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Storage Information'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Local Storage Implementation', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  '• Media files are stored locally in current device\n'
                  '• Files are saved in the app\'s private storage\n'
                  '• This implementation is not used firebase storage due to firebase storage limitations\n',
                ),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} - Media'),
        actions: [IconButton(icon: const Icon(Icons.info_outline), onPressed: _showStorageInfo)],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Images', icon: Icon(Icons.image)),
            Tab(text: 'Videos', icon: Icon(Icons.video_library)),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildImagesTab(), _buildVideosTab()]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _pickImage();
          } else {
            _pickVideo();
          }
        },
        backgroundColor: AppColors.primary,
        child: Icon(_tabController.index == 0 ? Icons.add_a_photo : Icons.videocam),
      ),
    );
  }

  Widget _buildImagesTab() {
    if (_images.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No images yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap the + button to add images', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final imagePath = _images[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.download, color: Colors.white, size: 20),
                      onPressed: () => _downloadImage(imagePath),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosTab() {
    if (_videos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No videos yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap the + button to add videos', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final videoPath = _videos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.play_circle_outline, size: 30, color: AppColors.primary),
            ),
            title: Text('Video ${index + 1}'),
            subtitle: const Text('Tap to play'),
            trailing: IconButton(icon: const Icon(Icons.download), onPressed: () => _downloadVideo(videoPath)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoPath: videoPath)),
              );
            },
          ),
        );
      },
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error initializing video player: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Video Player', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child:
            _isInitialized
                ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller),
                      _PlayPauseOverlay(controller: _controller),
                      _VideoProgressIndicator(_controller, allowScrubbing: true),
                    ],
                  ),
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({required this.controller});

  @override
  State<_PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  bool _hideControls = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _hideControls = !_hideControls;
        });
      },
      child: AnimatedOpacity(
        opacity: _hideControls ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Stack(
          children: [
            Container(color: Colors.black26),
            Center(
              child: IconButton(
                icon: Icon(
                  widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 60.0,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    widget.controller.value.isPlaying ? widget.controller.pause() : widget.controller.play();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoProgressIndicator extends StatelessWidget {
  final VideoPlayerController controller;
  final bool allowScrubbing;

  const _VideoProgressIndicator(this.controller, {required this.allowScrubbing});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black26,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    thumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white24,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                  ),
                  child: Slider(
                    value: value.position.inMilliseconds.toDouble(),
                    min: 0.0,
                    max: value.duration.inMilliseconds.toDouble(),
                    onChanged:
                        allowScrubbing
                            ? (newPosition) {
                              controller.seekTo(Duration(milliseconds: newPosition.round()));
                            }
                            : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(value.position), style: const TextStyle(color: Colors.white)),
                      Text(_formatDuration(value.duration), style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
