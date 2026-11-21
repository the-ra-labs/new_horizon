import 'dart:ui' as ui;
import 'package:flutter/material.dart';

enum SmartFit { auto, cover, contain }

/// Koi bhi photo, kisi bhi frame mein sahi fit:
///  - frame se milta ratio  -> poora bhar deta hai (cover)
///  - bohat alag ratio      -> poori photo dikhata hai + peeche dhundla background
class SmartImage extends StatefulWidget {
  final ImageProvider provider;
  final Alignment alignment; // cover mein photo ka kaun sa hissa dikhna chahiye
  final SmartFit fit;
  final double maxCrop; // is se zyada ratio farq ho to contain + blur
  final Widget? fallback; // photo load hone tak / na milne par

  const SmartImage(
    this.provider, {
    super.key,
    this.alignment = Alignment.center,
    this.fit = SmartFit.auto,
    this.maxCrop = 1.9,
    this.fallback,
  });

  SmartImage.asset(
    String path, {
    Key? key,
    Alignment alignment = Alignment.center,
    SmartFit fit = SmartFit.auto,
    double maxCrop = 1.9,
    Widget? fallback,
  }) : this(AssetImage(path),
            key: key,
            alignment: alignment,
            fit: fit,
            maxCrop: maxCrop,
            fallback: fallback);

  /// Agay ke liye: server se aane wali photos
  SmartImage.network(
    String url, {
    Key? key,
    Alignment alignment = Alignment.center,
    SmartFit fit = SmartFit.auto,
    double maxCrop = 1.9,
    Widget? fallback,
  }) : this(NetworkImage(url),
            key: key,
            alignment: alignment,
            fit: fit,
            maxCrop: maxCrop,
            fallback: fallback);

  @override
  State<SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends State<SmartImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  double? _ratio; // width / height
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant SmartImage old) {
    super.didUpdateWidget(old);
    if (old.provider != widget.provider) _resolve();
  }

  void _resolve() {
    final stream =
        widget.provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stop();
    _stream = stream;
    _ratio = null;
    _failed = false;
    _listener = ImageStreamListener(_onImage, onError: _onError);
    stream.addListener(_listener!);
  }

  void _onImage(ImageInfo info, bool sync) {
    final h = info.image.height;
    if (!mounted || h == 0) return;
    setState(() {
      _ratio = info.image.width / h;
      _failed = false;
    });
  }

  void _onError(Object error, StackTrace? stack) {
    if (mounted) setState(() => _failed = true);
  }

  void _stop() {
    final s = _stream;
    final l = _listener;
    if (s != null && l != null) s.removeListener(l);
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  Widget _img(BoxFit fit) => Image(
        image: widget.provider,
        fit: fit,
        alignment: widget.alignment,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      );

  Widget _fitted(BoxConstraints box, double r) {
    var cover = true;
    if (box.hasBoundedWidth && box.hasBoundedHeight && box.maxHeight > 0) {
      final fr = box.maxWidth / box.maxHeight;
      final f = r > fr ? r / fr : fr / r;
      cover = switch (widget.fit) {
        SmartFit.cover => true,
        SmartFit.contain => false,
        SmartFit.auto => f <= widget.maxCrop,
      };
    }
    if (cover) return _img(BoxFit.cover);

    return Stack(fit: StackFit.expand, children: [
      ClipRect(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: _img(BoxFit.cover),
        ),
      ),
      const ColoredBox(color: Color(0x66000000)),
      _img(BoxFit.contain),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final r = _ratio;
    return Stack(fit: StackFit.expand, children: [
      widget.fallback ?? const SizedBox.shrink(),
      if (r != null && !_failed)
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 280),
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: LayoutBuilder(builder: (context, box) => _fitted(box, r)),
        ),
    ]);
  }
}
