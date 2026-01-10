import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PinInputDisplay extends StatelessWidget {
  final int pinLength;
  final int currentLength;
  final bool isError;

  const PinInputDisplay({
    super.key,
    required this.pinLength,
    required this.currentLength,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(pinLength, (index) {
          bool isFilled = index < currentLength;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled
                  ? (isError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).primaryColor)
                  : Colors.transparent,
              border: Border.all(
                color: isError
                    ? Theme.of(context).colorScheme.error
                    : (isFilled
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.outline),
                width: 2,
              ),
            ),
            child: isFilled
                ? Icon(Icons.circle, color: Colors.white, size: 4.w)
                : null,
          );
        }),
      ),
    );
  }
}
