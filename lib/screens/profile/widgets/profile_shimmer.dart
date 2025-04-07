import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContent extends StatelessWidget {
  const ShimmerContent();

  Widget shimmerBox({double width = double.infinity, double height = 16}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Аят
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerBox(height: 18),
                    const SizedBox(height: 8),
                    shimmerBox(height: 14),
                    const SizedBox(height: 4),
                    shimmerBox(width: 100, height: 12),
                    const SizedBox(height: 20),
                  ],
                ),
            
                // Аватар
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: const CircleAvatar(radius: 50, backgroundColor: Colors.white),
                ),
                const SizedBox(height: 10),
                shimmerBox(width: 100, height: 20), // Ник
                const SizedBox(height: 6),
                shimmerBox(width: 160, height: 14), // Email
                const SizedBox(height: 4),
                shimmerBox(width: 220, height: 14), // Био
            
                const SizedBox(height: 20),
            
                // Карточка статистики
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      shimmerBox(width: double.infinity, height: 18),
                      const SizedBox(height: 12),
                      shimmerBox(width: double.infinity, height: 18),
                    ],
                  ),
                ),
            
                const SizedBox(height: 20),
            
                // Кнопки меню
                Row(
                  children: [
                    Expanded(child: shimmerBox(height: 48)),
                    const SizedBox(width: 12),
                    Expanded(child: shimmerBox(height: 48)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
