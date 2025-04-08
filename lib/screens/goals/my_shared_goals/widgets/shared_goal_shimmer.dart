import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SharedGoalShimmer extends StatelessWidget {
  const SharedGoalShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, width: 150, color: Colors.white),
              const SizedBox(height: 10),
              Container(height: 14, width: 200, color: Colors.white),
              const SizedBox(height: 14),
              Container(height: 8, width: double.infinity, color: Colors.white),
              const SizedBox(height: 10),
              Container(height: 14, width: 100, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}