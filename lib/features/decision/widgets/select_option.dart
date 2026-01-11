import 'package:flutter/material.dart';
import '../../../config/theme/spacing_tokens.dart';

class SelectOption extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SelectOption({super.key, required this.label, required this.selected, required this.onTap});

  @override
  State<SelectOption> createState() => _SelectOptionState();
}

class _SelectOptionState extends State<SelectOption> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.selected;
    
    // Premium color palette
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    
    // Selected state: Vibrant gradient with strong presence
    final selectedGradient = LinearGradient(
      colors: [
        primaryColor,
        primaryColor.withOpacity(0.85),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    // Unselected state: Subtle glassmorphism with better contrast
    final unselectedBg = surfaceColor.withOpacity(0.7);
    final unselectedBorder = theme.colorScheme.onSurface.withOpacity(0.15);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            margin: const EdgeInsets.only(right: 10, bottom: 12),
            decoration: BoxDecoration(
              // Gradient for selected, solid for unselected
              gradient: isSelected ? selectedGradient : null,
              color: isSelected ? null : unselectedBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? primaryColor.withOpacity(0.3)
                    : (_isHovered 
                        ? theme.colorScheme.onSurface.withOpacity(0.25) 
                        : unselectedBorder),
                width: isSelected ? 2.5 : 2.0,
              ),
              boxShadow: [
                // Elevated shadow for selected
                if (isSelected)
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                // Subtle depth for unselected
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.05),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: Offset(0, _isHovered ? 4 : 2),
                    spreadRadius: 0,
                  ),
                // Inner glow for selected
                if (isSelected)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                    spreadRadius: -4,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkmark icon for selected state (leading)
                if (isSelected) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected 
                          ? Colors.white 
                          : theme.colorScheme.onSurface.withOpacity(0.85),
                      letterSpacing: 0.2,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
