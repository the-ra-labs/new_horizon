import '../data/staff_data.dart';

export '../data/staff_data.dart' show AccountRole, AccountStatus;

/// DEMO ONLY. Asli app mein ye sab backend (hashed passwords + server-side
/// roles) ka kaam hai. Yahan sab kuch memory mein hai, app band hone par reset.
class AuthDemo {
  static final Set<String> _clients = {};

  static String _k(String s) => s.trim().toLowerCase();

  static void register({
    required List<String> ids,
    required AccountRole role,
    String name = '',
    String email = '',
    String phone = '',
    String password = '',
  }) {
    if (role == AccountRole.staff) {
      final n = name.trim().isEmpty ? 'New Staff' : name.trim();
      StaffStore.add(StaffMember(
        id: StaffStore.nextId(),
        name: n,
        email: email.trim(),
        phone: phone.trim(),
        password: password,
        role: StaffRole.agent,
        status: AccountStatus.pending,
        title: 'Advisor',
      ));
      ActivityStore.log(n, 'requested staff access');
    } else {
      for (final id in ids) {
        _clients.add(_k(id));
      }
    }
  }

  static AccountStatus? statusOf(String id) {
    final m = StaffStore.byContact(id);
    if (m != null) return m.status;
    return _clients.contains(_k(id)) ? AccountStatus.approved : null;
  }

  /// Approved staff member (agar ye id staff ki hai)
  static StaffMember? staffFor(String id) {
    final m = StaffStore.byContact(id);
    return (m != null && m.status == AccountStatus.approved) ? m : null;
  }

  static bool passwordOk(String id, String pw) {
    final m = StaffStore.byContact(id);
    return m == null || m.password == pw;
  }

  static void approve(String id) {
    final m = StaffStore.byContact(id);
    if (m != null) {
      m.status = AccountStatus.approved;
      StaffStore.notify();
    }
  }
}