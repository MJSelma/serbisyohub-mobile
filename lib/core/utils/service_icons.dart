import 'package:flutter/material.dart';

IconData iconFor(String category) => switch (category) {
  'cleaning' => Icons.cleaning_services_outlined,
  'aircon' => Icons.ac_unit,
  'plumbing' => Icons.plumbing,
  'electrical' => Icons.electrical_services_outlined,
  'beauty' => Icons.spa_outlined,
  'tutoring' => Icons.school_outlined,
  'events' => Icons.camera_alt_outlined,
  'vehicle' => Icons.car_repair,
  _ => Icons.handyman_outlined,
};
