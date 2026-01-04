import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

enum NotesViewType { grid, list }

class NotesShimmerLoader extends StatelessWidget {
  final NotesViewType viewType;
  final int itemCount;

  const NotesShimmerLoader({
    super.key,
    required this.viewType,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return viewType == NotesViewType.grid
        ? _buildGridShimmer()
        : _buildListShimmer();
  }

  Widget _buildGridShimmer() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, __) => _shimmerCard(borderRadius: 12),
    );
  }

  Widget _buildListShimmer() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: itemCount,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.only(bottom: 1.5.h),
        child: _shimmerCard(height: 120, borderRadius: 10),
      ),
    );
  }

  Widget _shimmerCard({double? height, required double borderRadius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
