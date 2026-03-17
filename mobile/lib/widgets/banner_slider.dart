import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flyem_app/services/content_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// سلايدر البنرات الإعلانية بعرض كامل الشاشة (مرتبط بلوحة التحكم).
class BannerSlider extends StatefulWidget {
  const BannerSlider({
    super.key,
    required this.banners,
    this.height = 180,
    this.autoPlayDuration = const Duration(seconds: 4),
  });

  final List<BannerItem> banners;
  final double height;
  final Duration autoPlayDuration;

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(widget.autoPlayDuration, (_) => _nextPage());
    }
  }

  void _nextPage() {
    if (!_pageController.hasClients || widget.banners.isEmpty) return;
    final next = (_currentPage + 1) % widget.banners.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.banners.length,
            itemBuilder: (_, index) {
              final b = widget.banners[index];
              return _BannerPage(
                imageUrl: b.imageUrl,
                videoUrl: b.videoUrl,
                title: b.title,
                link: b.link,
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == i
                      ? Colors.black87
                      : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BannerPage extends StatelessWidget {
  const _BannerPage({
    this.imageUrl,
    this.videoUrl,
    this.title = '',
    this.link,
  });

  final String? imageUrl;
  final String? videoUrl;
  final String title;
  final String? link;

  static Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Icon(
        Icons.campaign_outlined,
        size: 48,
        color: Colors.grey[500],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (link == null || link!.trim().isEmpty) return;
        final uri = Uri.tryParse(link!);
        if (uri == null) return;
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          }
        } catch (_) {}
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: videoUrl != null && videoUrl!.isNotEmpty
            ? _BannerVideoPlayer(videoUrl: videoUrl!, link: link)
            : imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    gaplessPlayback: true,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          child,
                          if (progress.expectedTotalBytes != null)
                            CircularProgressIndicator(
                              value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                              color: Colors.grey[600],
                            ),
                        ],
                      );
                    },
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
      ),
    );
  }
}

class _BannerVideoPlayer extends StatefulWidget {
  const _BannerVideoPlayer({required this.videoUrl, this.link});

  final String videoUrl;
  final String? link;

  @override
  State<_BannerVideoPlayer> createState() => _BannerVideoPlayerState();
}

class _BannerVideoPlayerState extends State<_BannerVideoPlayer> {
  VideoPlayerController? _controller;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true)
      ..setVolume(0);
    _controller!.initialize().then((_) {
      if (mounted && !_error) {
        setState(() {});
        _controller!.play();
      }
    }).catchError((_) {
      if (mounted) setState(() => _error = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openLink() async {
    final link = widget.link?.trim();
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_error || _controller == null) {
      return _BannerPage._placeholder();
    }
    if (!_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final videoContent = SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
    if (widget.link != null && widget.link!.trim().isNotEmpty) {
      return GestureDetector(
        onTap: _openLink,
        behavior: HitTestBehavior.opaque,
        child: videoContent,
      );
    }
    return videoContent;
  }
}
