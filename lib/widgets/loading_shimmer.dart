import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Skeleton shimmer loading — pengganti CircularProgressIndicator.
class LoadingShimmer extends StatefulWidget {
  final int itemCount;
  final double itemHeight;

  const LoadingShimmer({super.key, this.itemCount = 5, this.itemHeight = 72});

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              height: widget.itemHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                gradient: LinearGradient(
                  begin: Alignment(-1 - _controller.value * 2, 0),
                  end: Alignment(1 - _controller.value * 2, 0),
                  colors: const [
                    Color(0xFFEDEFF3),
                    Color(0xFFF7F8FA),
                    Color(0xFFEDEFF3),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
