import 'package:flutter/material.dart';
 import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';

class BuildByWidget extends StatelessWidget {
  const BuildByWidget({super.key});

  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _getPackageInfo(),
      builder: (context, snapshot) {
        final versionText = snapshot.hasData
            ? 'Version : ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : 'Version : --';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(),

            const SizedBox(height: 6),
            Text(
              versionText,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.flash_on_rounded,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 8),
                Text(
                  'Powered by Yak Stack Solution',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.sp),
        gradient: const LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/3.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
