import 'package:flutter/foundation.dart';

class SavedStore {
  static final ValueNotifier<Set<String>> ids = ValueNotifier<Set<String>>({});

  static bool has(String id) => ids.value.contains(id);

  /// true = saved hua, false = remove hua
  static bool toggle(String id) {
    final s = {...ids.value};
    final added = s.add(id);
    if (!added) s.remove(id);
    ids.value = s;
    return added;
  }
}

class ViewingRequest {
  final String ref;
  final String property;
  final String client;
  final String mode;
  final int guests;
  String date;
  String time;
  String status; // Pending | Confirmed | Completed | Cancelled
  String? assignedTo; // staff id

  ViewingRequest({
    required this.ref,
    required this.property,
    required this.date,
    required this.time,
    required this.mode,
    required this.guests,
    this.client = 'Respected Investor',
    this.status = 'Pending',
    this.assignedTo,
  });
}

class ViewingStore {
  /// Client ki apni requests
  static final ValueNotifier<List<ViewingRequest>> items =
  ValueNotifier<List<ViewingRequest>>([]);

  /// Staff ko sab clients ki requests dikhti hain
  static final ValueNotifier<List<ViewingRequest>> all =
  ValueNotifier<List<ViewingRequest>>(_seed());

  static List<ViewingRequest> _seed() => [
    ViewingRequest(
        ref: 'VV-3101',
        property: '10 Marla House',
        client: 'Hamza Ali Khan',
        date: '8 Nov 2026',
        time: '11:00 AM',
        mode: 'Chauffeur',
        guests: 2,
        assignedTo: 'ST-1005'),
    ViewingRequest(
        ref: 'VV-3102',
        property: '1 Kanal Villa',
        client: 'Sara Ahmed',
        date: '9 Nov 2026',
        time: '02:00 PM',
        mode: 'Helicopter',
        guests: 3,
        status: 'Confirmed',
        assignedTo: 'ST-1006'),
    ViewingRequest(
        ref: 'VV-3103',
        property: '8 Marla Shop',
        client: 'Omar Farooq',
        date: '12 Nov 2026',
        time: '04:00 PM',
        mode: 'Chauffeur',
        guests: 1),
    ViewingRequest(
        ref: 'VV-3104',
        property: '4 Marla Commercial Plot',
        client: 'Bilal Chaudhry',
        date: '3 Nov 2026',
        time: '10:00 AM',
        mode: 'Private Jet',
        guests: 2,
        status: 'Completed',
        assignedTo: 'ST-1002'),
  ];

  /// Client ki request: dono lists mein
  static void add(ViewingRequest r) {
    items.value = [r, ...items.value];
    all.value = [r, ...all.value];
  }

  /// Staff ki banayi hui booking: sirf staff list mein
  static void addStaff(ViewingRequest r) => all.value = [r, ...all.value];

  static void notifyAll() {
    all.value = [...all.value];
    items.value = [...items.value];
  }
}