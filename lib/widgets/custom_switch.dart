import 'package:flutter/material.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class CustomSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const CustomSwitch({
    Key? key,
    this.initialValue = false,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late bool isOn;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialValue;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (isOn) _controller.forward();
  }

  /// Re-sync when the parent's value changes.
  ///
  /// Without this the switch was uncontrolled: it painted from a local flip and
  /// never followed the parent again, so it could sit OFF while the screen said
  /// 2FA was enabled. Web's Switch is fully controlled (`checked={...}`).
  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        isOn != widget.initialValue) {
      setState(() => isOn = widget.initialValue);
      if (isOn) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void toggleSwitch() {
    // Controlled: report the intent and let the parent decide. The knob only
    // moves when the parent's value actually changes (via didUpdateWidget), so
    // a tap the parent refuses — e.g. turning 2FA off before the disable code
    // is verified — no longer leaves the knob lying about the real state.
    widget.onChanged?.call(!isOn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 35,
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isOn ? blueColor : Colors.grey.shade400,
        ),
        child: Align(
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
