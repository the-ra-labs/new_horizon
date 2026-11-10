import 'dart:math';
import 'package:flutter/material.dart';
import 'listings.dart';
import 'stores.dart';

enum AccountRole { client, staff }

enum AccountStatus { approved, pending }

enum StaffRole { ceo, manager, agent }

extension StaffRoleX on StaffRole {
  String get label => switch (this) {
    StaffRole.ceo => 'CEO',
    StaffRole.manager => 'Director',
    StaffRole.agent => 'Advisor',
  };

  Color get color => switch (this) {
    StaffRole.ceo => const Color(0xFFFFC46B),
    StaffRole.manager => const Color(0xFFFFB57D),
    StaffRole.agent => const Color(0xFF8AB4F8),
  };

  bool get manageTeam => this == StaffRole.ceo;
  bool get approveStaff => this == StaffRole.ceo;
  bool get deleteListings => this != StaffRole.agent;
  bool get assignWork => this != StaffRole.agent;
  bool get seeAll => this != StaffRole.agent;
  bool get deleteLeads => this != StaffRole.agent;
}

// ---------------------------------------------------------------- Session

class Session {
  static StaffMember? staff; // null = client
  static bool previewing = false; // staff "Client View" mein hai
}

// ---------------------------------------------------------------- Staff

class StaffMember {
  final String id;
  String name, email, phone, password;
  String title, credentials, focus, portfolio, languages, region;
  StaffRole role;
  AccountStatus status;
  double rating;
  String? image;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.status = AccountStatus.approved,
    this.title = '',
    this.credentials = '',
    this.focus = '',
    this.portfolio = '',
    this.languages = 'EN',
    this.region = '',
    this.rating = 5.0,
    this.image,
  });

  String get initials {
    final w = name.trim().split(RegExp(r'\s+'));
    if (w.isEmpty || w.first.isEmpty) return '?';
    if (w.length == 1) return w.first[0].toUpperCase();
    return (w.first[0] + w.last[0]).toUpperCase();
  }
}

class StaffStore {
  static final ValueNotifier<List<StaffMember>> members =
  ValueNotifier<List<StaffMember>>(_seed());

  static List<StaffMember> _seed() => [
    StaffMember(
      id: 'ST-1001',
      name: 'Lord Alistair Sterling',
      email: 'ceo@horizon.ae',
      phone: '+923001000001',
      password: 'Ceo@12345',
      role: StaffRole.ceo,
      title: 'Chief Executive Officer & Founder',
      credentials: 'FRICS',
      focus: 'Strategy & Acquisitions',
      portfolio: '\$1.8B+ Closed',
      languages: 'EN • AR',
      region: 'London & Dubai',
      image: 'assets/images/staff/ceo.jpg',
    ),
    StaffMember(
      id: 'ST-1002',
      name: 'Elena Vance',
      email: 'elena@horizon.ae',
      phone: '+923001000002',
      password: 'Manager@123',
      role: StaffRole.manager,
      title: 'Senior Equity Partner',
      credentials: 'CRE • MBA Wharton',
      focus: 'Commercial & Land',
      portfolio: '\$420M Portfolio',
      languages: 'EN • FR',
      region: 'London',
      image: 'assets/images/staff/elena.jpg',
    ),
    StaffMember(
      id: 'ST-1003',
      name: 'Julian Hargrove',
      email: 'julian@horizon.ae',
      phone: '+923001000003',
      password: 'Manager@123',
      role: StaffRole.manager,
      title: 'Managing Partner',
      credentials: 'Estates • MSc Oxford',
      focus: 'Private Estates',
      portfolio: '\$610M Portfolio',
      languages: 'EN • DE',
      region: 'Mayfair',
      image: 'assets/images/staff/julian.jpg',
    ),
    StaffMember(
      id: 'ST-1004',
      name: 'Amira Haddad',
      email: 'amira@horizon.ae',
      phone: '+923001000004',
      password: 'Manager@123',
      role: StaffRole.manager,
      title: 'Partner, Global Markets',
      credentials: 'Cross-border • LSE',
      focus: 'Gulf & Europe',
      portfolio: '\$310M Portfolio',
      languages: 'EN • AR',
      region: 'Dubai',
      image: 'assets/images/staff/amira.jpg',
    ),
    StaffMember(
      id: 'ST-1005',
      name: 'Marcus Thorne',
      email: 'marcus@horizon.ae',
      phone: '+923001000005',
      password: 'Agent@123',
      role: StaffRole.agent,
      title: 'Waterfront & Island Lead',
      focus: 'Waterfront',
      portfolio: '14 Exclusive Mandates',
      languages: 'EN • FR • IT',
      region: "Côte d'Azur & Miami",
      image: 'assets/images/staff/marcus.jpg',
    ),
    StaffMember(
      id: 'ST-1006',
      name: 'Seraphina Rossi',
      email: 'seraphina@horizon.ae',
      phone: '+923001000006',
      password: 'Agent@123',
      role: StaffRole.agent,
      title: 'Historic Estates Specialist',
      focus: 'Historic Estates',
      portfolio: '9 Exclusive Mandates',
      languages: 'EN • ES • AR',
      region: 'Tuscany & London',
      image: 'assets/images/staff/seraphina.jpg',
    ),
    // Pending registrations (CEO approve karega)
    StaffMember(
      id: 'ST-1007',
      name: 'Daniyal Qureshi',
      email: 'daniyal@mail.com',
      phone: '+923214445566',
      password: 'Staff@123',
      role: StaffRole.agent,
      status: AccountStatus.pending,
      title: 'Advisor',
    ),
    StaffMember(
      id: 'ST-1008',
      name: 'Hira Malik',
      email: 'hira@mail.com',
      phone: '+923335556677',
      password: 'Staff@123',
      role: StaffRole.agent,
      status: AccountStatus.pending,
      title: 'Advisor',
    ),
  ];

  static String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  static StaffMember? byContact(String c) {
    final q = c.trim().toLowerCase();
    if (q.isEmpty) return null;
    final qd = _digits(q);
    for (final m in members.value) {
      if (m.email.toLowerCase() == q) return m;
      if (qd.length >= 10 && _digits(m.phone) == qd) return m;
    }
    return null;
  }

  static StaffMember? byId(String? id) {
    if (id == null) return null;
    for (final m in members.value) {
      if (m.id == id) return m;
    }
    return null;
  }

  static bool contactTaken(String email, String phone, {String? exceptId}) {
    final e = email.trim().toLowerCase();
    final p = _digits(phone);
    return members.value.any((m) =>
    m.id != exceptId &&
        ((e.isNotEmpty && m.email.toLowerCase() == e) ||
            (p.length >= 10 && _digits(m.phone) == p)));
  }

  static List<StaffMember> get approved => members.value
      .where((m) => m.status == AccountStatus.approved)
      .toList();

  static List<StaffMember> get pending => members.value
      .where((m) => m.status == AccountStatus.pending)
      .toList();

  static void add(StaffMember m) => members.value = [...members.value, m];

  static void remove(String id) =>
      members.value = members.value.where((m) => m.id != id).toList();

  static void notify() => members.value = [...members.value];

  static String nextId() {
    final r = Random();
    String id;
    do {
      id = 'ST-${1000 + r.nextInt(9000)}';
    } while (byId(id) != null);
    return id;
  }
}

// ---------------------------------------------------------------- Leads

enum LeadStatus { fresh, contacted, viewing, negotiation, won, lost }

extension LeadStatusX on LeadStatus {
  String get label => switch (this) {
    LeadStatus.fresh => 'New',
    LeadStatus.contacted => 'Contacted',
    LeadStatus.viewing => 'Viewing',
    LeadStatus.negotiation => 'Negotiation',
    LeadStatus.won => 'Won',
    LeadStatus.lost => 'Lost',
  };

  Color get color => switch (this) {
    LeadStatus.fresh => const Color(0xFF8AB4F8),
    LeadStatus.contacted => const Color(0xFFFFB57D),
    LeadStatus.viewing => const Color(0xFFF7A10A),
    LeadStatus.negotiation => const Color(0xFFD4E157),
    LeadStatus.won => const Color(0xFF3DDC84),
    LeadStatus.lost => const Color(0xFFFF5C5C),
  };
}

class Lead {
  final String id;
  String name, phone, email, notes, source;
  int budget;
  String? listingId;
  LeadStatus status;
  String? assignedTo;
  final DateTime created;

  Lead({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.notes = '',
    this.source = 'Website',
    this.budget = 0,
    this.listingId,
    this.status = LeadStatus.fresh,
    this.assignedTo,
    DateTime? created,
  }) : created = created ?? DateTime.now();
}

class LeadStore {
  static final ValueNotifier<List<Lead>> items =
  ValueNotifier<List<Lead>>(_seed());

  static List<Lead> _seed() {
    const names = [
      'Hamza Ali Khan', 'Sara Ahmed', 'Bilal Chaudhry', 'Ayesha Siddiqui',
      'Omar Farooq', 'Zainab Malik', 'Usman Sheikh', 'Mariam Raza',
      'Tariq Mehmood',
    ];
    const sources = [
      'Website', 'Referral', 'Walk-in', 'WhatsApp', 'Instagram',
      'Facebook', 'Website', 'Referral', 'WhatsApp',
    ];
    const statuses = [
      LeadStatus.fresh, LeadStatus.contacted, LeadStatus.viewing,
      LeadStatus.negotiation, LeadStatus.fresh, LeadStatus.won,
      LeadStatus.contacted, LeadStatus.lost, LeadStatus.negotiation,
    ];
    final owners = <String?>[
      'ST-1005', 'ST-1006', 'ST-1002', 'ST-1005', null,
      'ST-1006', 'ST-1002', 'ST-1005', null,
    ];
    const budgets = [
      35000000, 12000000, 90000000, 18000000, 60000000,
      25000000, 7500000, 42000000, 120000000,
    ];
    const notes = [
      'Prefers corner plots. Call after 5 PM.',
      '',
      'Overseas investor, wants video tour.',
      'Needs installment plan.',
      '',
      'Deal closed. Documents in progress.',
      'Comparing with Phase 3 options.',
      'Budget too low for requirement.',
      'Cash buyer, decision this week.',
    ];
    return [
      for (var i = 0; i < names.length; i++)
        Lead(
          id: 'LD-${1001 + i}',
          name: names[i],
          phone: '+9230${2000000 + i * 91357}',
          email: i.isEven
              ? '${names[i].split(' ').first.toLowerCase()}@mail.com'
              : '',
          notes: notes[i],
          source: sources[i],
          budget: budgets[i],
          listingId: allListings[(i * 17 + 3) % allListings.length].id,
          status: statuses[i],
          assignedTo: owners[i],
          created: DateTime.now().subtract(Duration(days: i, hours: i * 2)),
        ),
    ];
  }

  static String nextId() {
    final r = Random();
    String id;
    do {
      id = 'LD-${1000 + r.nextInt(9000)}';
    } while (items.value.any((l) => l.id == id));
    return id;
  }

  static void add(Lead l) => items.value = [l, ...items.value];

  static void remove(String id) =>
      items.value = items.value.where((l) => l.id != id).toList();

  static void notify() => items.value = [...items.value];
}

// ---------------------------------------------------------------- Activity

class ActivityStore {
  static final ValueNotifier<List<(DateTime, String)>> items =
  ValueNotifier<List<(DateTime, String)>>(_seed());

  static List<(DateTime, String)> _seed() => [
    (
    DateTime.now().subtract(const Duration(hours: 2)),
    'Marcus Thorne updated a listing'
    ),
    (
    DateTime.now().subtract(const Duration(hours: 5)),
    'Elena Vance added a new lead'
    ),
    (
    DateTime.now().subtract(const Duration(days: 1)),
    'Lord Alistair Sterling approved Seraphina Rossi'
    ),
  ];

  static void log(String actor, String text) {
    items.value = [
      (DateTime.now(), '$actor $text'),
      ...items.value.take(49),
    ];
  }
}

// ---------------------------------------------------------------- Listings

class ListingStore {
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void _bump() => revision.value++;

  static void add(Listing l) {
    allListings.insert(0, l);
    _bump();
  }

  static void update(Listing l) {
    final i = allListings.indexWhere((e) => e.id == l.id);
    if (i >= 0) allListings[i] = l;
    _bump();
  }

  static void remove(String id) {
    allListings.removeWhere((l) => l.id == id);
    SavedStore.ids.value = {...SavedStore.ids.value}..remove(id);
    _bump();
  }

  static String newId(ListingKind k) {
    final p = switch (k) {
      ListingKind.plot => 'P',
      ListingKind.building => 'B',
      ListingKind.plaza => 'PZ',
      ListingKind.shop => 'S',
      ListingKind.house => 'H',
    };
    final r = Random();
    String id;
    do {
      id = 'NH-$p-${2000 + r.nextInt(7999)}';
    } while (allListings.any((l) => l.id == id));
    return id;
  }
}