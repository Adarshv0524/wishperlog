import 'package:flutter/physics.dart';

const thoughtNotchSpring = SpringDescription(
  mass: 1,
  stiffness: 280,
  damping: 26,
);
const saveConfirmSpring = SpringDescription(
  mass: 1,
  stiffness: 240,
  damping: 22,
);
const screenNavSpring = SpringDescription(mass: 1, stiffness: 260, damping: 28);
