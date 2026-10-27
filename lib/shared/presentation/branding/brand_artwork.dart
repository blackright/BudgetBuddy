import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Accepted review-v2 artwork. The coin's dollar is decorative, never a currency.
class BrandArtwork extends StatelessWidget {
  const BrandArtwork({super.key, this.progress = 1, this.onAssetFailure});
  final VoidCallback? onAssetFailure;
  final double progress;

  double _part(double start, double end) =>
      ((progress - start) / (end - start)).clamp(0.0, 1.0);

  Widget _image(String name, IconData fallback) => Image.asset(
        'assets/branding/production/$name.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          final callback = onAssetFailure;
          if (callback != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => callback());
          }
          return Icon(fallback, size: 64, color: const Color(0xffb5f67c));
        },
      );

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: AspectRatio(
          aspectRatio: 1.45,
          child: LayoutBuilder(builder: (context, box) {
            final wallet = Curves.easeOut.transform(_part(.08, .5));
            final coin = _part(.15, .6);
            return Stack(clipBehavior: Clip.none, children: [
              Positioned(
                  left: box.maxWidth * .31,
                  top: 0,
                  width: box.maxWidth * .31,
                  child: Opacity(
                      opacity: coin,
                      child: Transform.scale(
                          scale: .92 + .08 * coin,
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withValues(
                                      alpha: .18 * math.sin(math.pi * coin)),
                                  BlendMode.srcATop),
                              child: _image(
                                  'coin', Icons.monetization_on_outlined))))),
              Positioned(
                  left: box.maxWidth * .4,
                  top: 0,
                  width: box.maxWidth * .65,
                  child: ClipRect(
                      clipper: _ArrowReveal(_part(.29, .71)),
                      child: const AspectRatio(
                          aspectRatio: 1.6,
                          child: CustomPaint(painter: _GrowthArrow())))),
              Positioned.fill(
                  child: Opacity(
                      opacity: wallet,
                      child: Transform.translate(
                          offset: Offset(0, 14 * (1 - wallet)),
                          child:
                              _image('wallet', Icons.account_balance_wallet)))),
            ]);
          })));
}

/// Native Canvas equivalent of the explicitly accepted SVG recreation.
class _GrowthArrow extends CustomPainter {
  const _GrowthArrow();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1024, size.height / 640);
    final path = Path()
      ..moveTo(95, 415)
      ..cubicTo(326, 492, 580, 392, 760, 201)
      ..lineTo(713, 171)
      ..quadraticBezierTo(694, 155, 718, 143)
      ..lineTo(900, 64)
      ..quadraticBezierTo(930, 49, 926, 82)
      ..lineTo(911, 277)
      ..quadraticBezierTo(909, 310, 886, 291)
      ..lineTo(840, 256)
      ..cubicTo(624, 510, 374, 579, 102, 497)
      ..quadraticBezierTo(72, 488, 69, 455)
      ..quadraticBezierTo(65, 429, 95, 415)
      ..close();
    const rect = Rect.fromLTWH(0, 0, 1024, 640);
    canvas.save();
    canvas.translate(0, 24);
    canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
                  colors: [Color(0xff07994f), Color(0xff067d4a)])
              .createShader(rect));
    canvas.restore();
    canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xff32d66b), Color(0xff74e64d), Color(0xffb0f345)],
              stops: [0, .54, 1]).createShader(rect));
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xff7cdb57)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GrowthArrow oldDelegate) => false;
}

Color brandBackground(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xff071f42)
    : const Color(0xff0876d5);

/// Live text stays readable independently of the decorative raster layers.
class BrandWelcome extends StatelessWidget {
  const BrandWelcome(
      {super.key,
      this.progress = 1,
      this.compact = false,
      this.onAssetFailure});
  final VoidCallback? onAssetFailure;
  final double progress;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final text = theme.textTheme
        .apply(bodyColor: Colors.white, displayColor: Colors.white);
    return DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [
                        Color(0xff09254e),
                        Color(0xff085f82),
                        Color(0xff0b4c42)
                      ]
                    : const [
                        Color(0xff075dd0),
                        Color(0xff037d99),
                        Color(0xff087365)
                      ])),
        child: DefaultTextStyle(
            style: text.bodyLarge!,
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 390),
                              child: BrandArtwork(
                                  progress: progress,
                                  onAssetFailure: onAssetFailure))),
                      const SizedBox(height: 22),
                      Opacity(
                          opacity: ((progress - .54) / .3).clamp(0.0, 1.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                    label: 'BudgetBuddy',
                                    header: true,
                                    excludeSemantics: true,
                                    child: Wrap(children: [
                                      Text('Budget',
                                          style: text.headlineLarge?.copyWith(
                                              fontWeight: FontWeight.w900)),
                                      Text('Buddy',
                                          style: text.headlineLarge?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xffb5f67c))),
                                    ])),
                                const SizedBox(height: 12),
                                const Text('Budget together. Grow together.'),
                              ])),
                      if (!compact) ...[
                        const SizedBox(height: 22),
                        Text('A brighter tomorrow, together.',
                            style: text.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 18),
                        Wrap(spacing: 16, runSpacing: 14, children: [
                          for (final item in [
                            (Icons.home_outlined, 'Plan'),
                            (Icons.check_rounded, 'Track'),
                            (Icons.favorite_border, 'Manage'),
                            (Icons.trending_up, 'Grow')
                          ])
                            SizedBox(
                                width: math.max(48,
                                    MediaQuery.textScalerOf(context).scale(48)),
                                child: Column(children: [
                                  ExcludeSemantics(
                                      child: Icon(item.$1,
                                          size: 28, color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Text(item.$2, textAlign: TextAlign.center),
                                ])),
                        ]),
                        const SizedBox(height: 22),
                        const Text('Small steps. Big goals.'),
                      ],
                      const SizedBox(height: 16),
                      const Text('by UzaTek'),
                    ]))));
  }
}

class _ArrowReveal extends CustomClipper<Rect> {
  const _ArrowReveal(this.fraction);
  final double fraction;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  @override
  bool shouldReclip(_ArrowReveal oldClipper) => fraction != oldClipper.fraction;
}
