import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:sizer/sizer.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onDeleteLongPressed;
  final bool isEnabled;

  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    this.onDeleteLongPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          // First row: 1, 2, 3
          _buildKeypadRow(['1', '2', '3'], context),
          SizedBox(height: 2.h),
          // Second row: 4, 5, 6
          _buildKeypadRow(['4', '5', '6'], context),
          SizedBox(height: 2.h),
          // Third row: 7, 8, 9
          _buildKeypadRow(['7', '8', '9'],context),
          SizedBox(height: 2.h),
          // Fourth row: empty, 0, delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 20.w, height: 8.h), // Empty space
              _buildKeypadButton('0',context),
              _buildDeleteButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers,BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildKeypadButton(number, context)).toList(),
    );
  }

  Widget _buildKeypadButton(String number, BuildContext context) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onNumberPressed(number);
            }
          : null,
      child: Container(
        width: 20.w,
        height: 8.h,
        decoration: BoxDecoration(
          color: isEnabled
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.3,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isEnabled
                ? () {
                    HapticFeedback.lightImpact();
                    onNumberPressed(number);
                  }
                : null,
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isEnabled
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onDeletePressed();
            }
          : null,
      onLongPress: isEnabled && onDeleteLongPressed != null
          ? () {
              HapticFeedback.mediumImpact();
              onDeleteLongPressed!();
            }
          : null,
      child: Container(
        width: 20.w,
        height: 8.h,
        decoration: BoxDecoration(
          color: isEnabled
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.3,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isEnabled
                ? () {
                    HapticFeedback.lightImpact();
                    onDeletePressed();
                  }
                : null,
            onLongPress: isEnabled && onDeleteLongPressed != null
                ? () {
                    HapticFeedback.mediumImpact();
                    onDeleteLongPressed!();
                  }
                : null,
            child: Center(
              child: CustomIconWidget(
                iconName: 'backspace',
                color: isEnabled
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                size: 6.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
