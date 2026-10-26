import 'package:flutter/material.dart';
import '../../../core/services/profile_name.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.name, this.radius = 20});
  final String name;
  final double radius;
  @override
  Widget build(BuildContext context) => Semantics(
      label:
          name.trim().isEmpty ? 'Personal profile' : 'Profile: ${name.trim()}',
      child: CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: ExcludeSemantics(
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(profileInitial(name),
                      key: ValueKey(profileInitial(name)),
                      style: const TextStyle(fontWeight: FontWeight.w700))))));
}
